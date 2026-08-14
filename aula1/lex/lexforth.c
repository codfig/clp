/* ===========================================================================
 * lexforth.c - analisador lexico para a linguagem Forth
 * ---------------------------------------------------------------------------
 * Implementado em C usando expressoes regulares POSIX (<regex.h>).
 * Material da aula 1 - Linguagens de Programacao.
 *
 * Compilar:  gcc -std=gnu99 -Wall -Wextra -O2 -o lexforth lexforth.c
 * Usar:      ./lexforth exemplo.fs
 *            ./lexforth -s ../forth/exemplos.fs      (so o resumo)
 *            cat arquivo.fs | ./lexforth             (le da entrada padrao)
 *
 * ---------------------------------------------------------------------------
 * COMO FUNCIONA
 *
 * O analisador usa a estrategia classica de "lista de regras + maximal munch":
 *
 *   1. Mantem um cursor na posicao atual do texto.
 *   2. Tenta cada regex da tabela ESTRUTURAIS, na ordem, sempre ancorada
 *      em ^ (ou seja, o casamento precisa comecar exatamente no cursor).
 *   3. A primeira que casar define o token; o cursor avanca o tamanho do
 *      casamento. Por isso a ORDEM DA TABELA E O ALGORITMO: as regras mais
 *      especificas (comentarios, strings, floats) vem antes das mais gerais
 *      (inteiro, palavra generica).
 *   4. Tokens numericos passam por uma checagem extra de DELIMITADOR: em
 *      Forth "12ABC" e uma palavra so, nao o numero 12 seguido de ABC.
 *      Como ERE nao tem lookahead, essa condicao e verificada em C.
 *   5. O que sobrar vira PALAVRA, e ai uma segunda tabela de regexes
 *      (PALAVRAS-CHAVE, ancoradas em ^...$) classifica a palavra em
 *      CONTROLE, PILHA, ARITMETICA, MEMORIA, etc.
 *
 * Essa separacao em duas fases e proposital: o regex reconhece a FORMA do
 * lexema, e a tabela de palavras-chave decide o SIGNIFICADO dele. E o mesmo
 * desenho que o lex/flex gera automaticamente.
 * ===========================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

/* --------------------------------------------------------------------------
 * Tipos de token
 * -------------------------------------------------------------------------- */

enum {
    T_SPACE = 0, T_COMMENT, T_STRING, T_FLOAT, T_INT, T_HEX, T_BIN, T_CHAR,
    T_DEF, T_CTRL, T_STACK, T_ARITH, T_CMP, T_MEM, T_IO, T_WORD, T_ERROR,
    T_COUNT
};

static const char *TOKEN_NAME[T_COUNT] = {
    "ESPACO", "COMENTARIO", "STRING", "FLOAT", "INTEIRO", "HEXADECIMAL",
    "BINARIO", "CARACTERE", "DEFINICAO", "CONTROLE", "PILHA", "ARITMETICA",
    "COMPARACAO", "MEMORIA", "ENTRADA-SAIDA", "PALAVRA", "ERRO"
};

/* --------------------------------------------------------------------------
 * Tabela 1: regras estruturais (reconhecem a FORMA do lexema)
 * A ordem importa - da regra mais especifica para a mais geral.
 * -------------------------------------------------------------------------- */

typedef struct {
    int         type;
    const char *pattern;
    int         needs_delim;  /* 1 = o lexema precisa terminar em delimitador */
    regex_t     re;
} Rule;

static Rule ESTRUTURAIS[] = {
    /* espaco em branco (descartado da saida) */
    { T_SPACE,   "^[ \t\r\n]+",                        0, {0} },

    /* comentario de linha:  \ ate o fim da linha  (a barra e uma PALAVRA) */
    { T_COMMENT, "^\\\\([ \t\r][^\n]*)?",              0, {0} },

    /* .( texto )  imprime o texto - vem ANTES da regra de ( comentario ) */
    { T_STRING,  "^\\.\\([^)\n]*\\)",                  0, {0} },

    /* comentario entre parenteses: este SIM pode atravessar varias linhas */
    { T_COMMENT, "^\\([ \t\r\n][^)]*\\)",              0, {0} },

    /* strings: S" ..."  C" ..."  ." ..."  ABORT" ..."
     * O [^"\n] proibe a quebra de linha de proposito: em Forth uma string
     * nao atravessa linha. Sem isso, uma aspa esquecida engole o resto do
     * arquivo ate achar a proxima aspa, escondendo o erro verdadeiro. */
    { T_STRING,  "^(S\"|C\"|\\.\"|ABORT\")[^\"\n]*\"", 0, {0} },

    /* ponto flutuante - precisa do expoente: 3.14e  1.5e-3  2e10 */
    { T_FLOAT,   "^[+-]?[0-9]+(\\.[0-9]*)?[eE][+-]?[0-9]*", 1, {0} },

    /* hexadecimal no estilo Forth ($FF) e no estilo C (0xFF) */
    { T_HEX,     "^[+-]?(\\$|0[xX])[0-9A-Fa-f]+",      1, {0} },

    /* binario: %1011 */
    { T_BIN,     "^[+-]?%[01]+",                       1, {0} },

    /* caractere literal: 'A' */
    { T_CHAR,    "^'[^']'",                            1, {0} },

    /* inteiro; o ponto final opcional marca literal de precisao dupla */
    { T_INT,     "^[+-]?[0-9]+\\.?",                   1, {0} },

    /* qualquer sequencia sem espaco vira PALAVRA (rede de seguranca) */
    { T_WORD,    "^[^ \t\r\n]+",                       0, {0} },
};

static const int N_ESTRUTURAIS = sizeof(ESTRUTURAIS) / sizeof(ESTRUTURAIS[0]);

/* --------------------------------------------------------------------------
 * Tabela 2: palavras-chave (decidem o SIGNIFICADO da palavra)
 * Todas ancoradas em ^...$ e compiladas com REG_ICASE, porque Forth nao
 * diferencia maiusculas de minusculas.
 * -------------------------------------------------------------------------- */

typedef struct {
    int         type;
    const char *pattern;
    regex_t     re;
} Keyword;

static Keyword PALAVRAS_CHAVE[] = {
    { T_DEF,
      "^(:|;|VARIABLE|2VARIABLE|CONSTANT|2CONSTANT|CREATE|DOES>|VALUE|TO"
      "|MARKER|DEFER|IS|IMMEDIATE|RECURSIVE)$", {0} },

    { T_CTRL,
      "^(IF|ELSE|THEN|BEGIN|UNTIL|WHILE|REPEAT|AGAIN|DO|\\?DO|LOOP|\\+LOOP"
      "|LEAVE|UNLOOP|EXIT|RECURSE|CASE|OF|ENDOF|ENDCASE|I|J|K)$", {0} },

    { T_STACK,
      "^(DUP|\\?DUP|DROP|SWAP|OVER|ROT|-ROT|NIP|TUCK|PICK|ROLL|DEPTH"
      "|2DUP|2DROP|2SWAP|2OVER|>R|R>|R@|CLEARSTACK)$", {0} },

    { T_ARITH,
      "^(\\+|-|\\*|/|MOD|/MOD|\\*/|\\*/MOD|1\\+|1-|2\\*|2/|NEGATE|ABS"
      "|MIN|MAX|AND|OR|XOR|INVERT|LSHIFT|RSHIFT"
      "|F\\+|F-|F\\*|F/|FSQRT|FDUP|FSWAP|FDROP|FNEGATE)$", {0} },

    { T_CMP,
      "^(=|<>|<|>|<=|>=|0=|0<|0>|0<>|U<|U>|WITHIN|TRUE|FALSE)$", {0} },

    { T_MEM,
      "^(@|!|\\+!|C@|C!|2@|2!|,|C,|CELLS|CELL|CELL\\+|CHARS|ALLOT|HERE"
      "|ALIGN|ALIGNED|MOVE|FILL|ERASE|DUMP)$", {0} },

    { T_IO,
      "^(\\.|\\.S|U\\.|\\.R|U\\.R|EMIT|KEY|TYPE|COUNT|CR|SPACE|SPACES"
      "|PAGE|F\\.|F\\.S|WORDS|SEE|BYE|INCLUDE|INCLUDED|THROW|CATCH)$", {0} },
};

static const int N_PALAVRAS_CHAVE =
    sizeof(PALAVRAS_CHAVE) / sizeof(PALAVRAS_CHAVE[0]);

/* --------------------------------------------------------------------------
 * Tabela 3: regexes de ABERTURA, usadas so para diagnosticar erro lexico.
 * Casam o inicio de um comentario ou de uma string SEM exigir o fechamento;
 * se uma delas casa mas a regra estrutural correspondente nao casou, e porque
 * o delimitador de fechamento esta faltando.
 * -------------------------------------------------------------------------- */

static regex_t RE_ABRE_COMENTARIO;   /* ^\([ \t\r\n]        */
static regex_t RE_ABRE_STRING;       /* ^(S"|C"|."|ABORT")  */

static const char *P_ABRE_COMENTARIO = "^\\([ \t\r\n]";
static const char *P_ABRE_STRING     = "^(S\"|C\"|\\.\"|ABORT\")";

/* --------------------------------------------------------------------------
 * Utilitarios
 * -------------------------------------------------------------------------- */

static void erro_fatal(const char *msg)
{
    fprintf(stderr, "lexforth: %s\n", msg);
    exit(1);
}

/* Compila todas as regexes das duas tabelas; aborta se alguma estiver errada. */
static void compilar_regexes(void)
{
    char buf[256];
    int  i, rc;

    for (i = 0; i < N_ESTRUTURAIS; i++) {
        rc = regcomp(&ESTRUTURAIS[i].re, ESTRUTURAIS[i].pattern,
                     REG_EXTENDED | REG_ICASE);
        if (rc != 0) {
            regerror(rc, &ESTRUTURAIS[i].re, buf, sizeof buf);
            fprintf(stderr, "regex invalida (%s): %s\n",
                    ESTRUTURAIS[i].pattern, buf);
            exit(1);
        }
    }
    for (i = 0; i < N_PALAVRAS_CHAVE; i++) {
        rc = regcomp(&PALAVRAS_CHAVE[i].re, PALAVRAS_CHAVE[i].pattern,
                     REG_EXTENDED | REG_ICASE);
        if (rc != 0) {
            regerror(rc, &PALAVRAS_CHAVE[i].re, buf, sizeof buf);
            fprintf(stderr, "regex invalida (%s): %s\n",
                    PALAVRAS_CHAVE[i].pattern, buf);
            exit(1);
        }
    }
    if (regcomp(&RE_ABRE_COMENTARIO, P_ABRE_COMENTARIO,
                REG_EXTENDED | REG_ICASE) != 0 ||
        regcomp(&RE_ABRE_STRING, P_ABRE_STRING,
                REG_EXTENDED | REG_ICASE) != 0)
        erro_fatal("regex de diagnostico invalida");
}

static void liberar_regexes(void)
{
    int i;
    for (i = 0; i < N_ESTRUTURAIS; i++)    regfree(&ESTRUTURAIS[i].re);
    for (i = 0; i < N_PALAVRAS_CHAVE; i++) regfree(&PALAVRAS_CHAVE[i].re);
    regfree(&RE_ABRE_COMENTARIO);
    regfree(&RE_ABRE_STRING);
}

static int eh_delimitador(char c)
{
    return c == '\0' || c == ' ' || c == '\t' || c == '\r' || c == '\n';
}

/* Le o arquivo inteiro para a memoria. Devolve o buffer terminado em '\0'. */
static char *ler_tudo(FILE *f, size_t *tamanho)
{
    size_t cap = 65536, len = 0, n;
    char  *buf = malloc(cap);

    if (!buf) erro_fatal("memoria insuficiente");
    while ((n = fread(buf + len, 1, cap - len - 1, f)) > 0) {
        len += n;
        if (len + 1 >= cap) {
            cap *= 2;
            buf = realloc(buf, cap);
            if (!buf) erro_fatal("memoria insuficiente");
        }
    }
    buf[len] = '\0';
    *tamanho = len;
    return buf;
}

/* Classifica uma PALAVRA usando a segunda tabela de regexes. */
static int classificar_palavra(const char *lexema)
{
    int i;
    for (i = 0; i < N_PALAVRAS_CHAVE; i++)
        if (regexec(&PALAVRAS_CHAVE[i].re, lexema, 0, NULL, 0) == 0)
            return PALAVRAS_CHAVE[i].type;
    return T_WORD;
}

/* Imprime o lexema em uma linha so, truncando o que for muito longo. */
static void imprimir_lexema(const char *s, size_t n)
{
    const size_t LIMITE = 44;
    size_t i, m = n > LIMITE ? LIMITE : n;

    putchar('"');
    for (i = 0; i < m; i++) {
        char c = s[i];
        if (c == '\n')      fputs("\\n", stdout);
        else if (c == '\t') fputs("\\t", stdout);
        else if (c == '\r') ;                       /* descarta CR do Windows */
        else                putchar(c);
    }
    if (n > LIMITE) fputs("...", stdout);
    putchar('"');
}

/* --------------------------------------------------------------------------
 * O analisador propriamente dito
 * -------------------------------------------------------------------------- */

typedef struct {
    long contagem[T_COUNT];
    long total;
    long erros;
} Estatisticas;

static void analisar(const char *src, int mostrar_tokens, int mostrar_comentarios,
                     Estatisticas *st)
{
    size_t pos = 0;
    long   linha = 1, coluna = 1;

    while (src[pos] != '\0') {
        regmatch_t m;
        int  i, tipo = -1;
        size_t tam = 0;

        /* ---- fase 1: descobrir a FORMA do lexema ---- */
        for (i = 0; i < N_ESTRUTURAIS; i++) {
            if (regexec(&ESTRUTURAIS[i].re, src + pos, 1, &m, 0) != 0)
                continue;
            if (m.rm_so != 0 || m.rm_eo <= 0)
                continue;

            /* numeros precisam terminar em delimitador: "12ABC" e palavra */
            if (ESTRUTURAIS[i].needs_delim &&
                !eh_delimitador(src[pos + (size_t)m.rm_eo]))
                continue;

            tipo = ESTRUTURAIS[i].type;
            tam  = (size_t)m.rm_eo;
            break;
        }

        /* Nenhuma regra casou: caractere solto e inclassificavel. */
        if (tipo < 0) {
            tipo = T_ERROR;
            tam  = 1;
        }

        /* ---- deteccao de erros lexicais ----
         * Se caiu em PALAVRA mas o texto COMECA como comentario ou string,
         * entao o delimitador de fechamento nunca apareceu. As regexes de
         * ABERTURA abaixo isolam exatamente esse caso. */
        if (tipo == T_WORD) {
            if (regexec(&RE_ABRE_COMENTARIO, src + pos, 0, NULL, 0) == 0) {
                fprintf(stderr, "%ld:%ld: erro lexico: comentario '(' sem ')'\n",
                        linha, coluna);
                tipo = T_ERROR;
                st->erros++;
                tam  = strlen(src + pos);   /* consome o resto: nao ha como seguir */
            }
            else if (regexec(&RE_ABRE_STRING, src + pos, 0, NULL, 0) == 0) {
                fprintf(stderr,
                        "%ld:%ld: erro lexico: string sem aspas de fechamento\n",
                        linha, coluna);
                tipo = T_ERROR;
                st->erros++;
                tam  = strcspn(src + pos, "\n");
            }
        }

        /* ---- fase 2: descobrir o SIGNIFICADO, se for palavra ---- */
        if (tipo == T_WORD) {
            char *lex = malloc(tam + 1);
            if (!lex) erro_fatal("memoria insuficiente");
            memcpy(lex, src + pos, tam);
            lex[tam] = '\0';
            tipo = classificar_palavra(lex);
            free(lex);
        }

        /* ---- contabilizar e imprimir ---- */
        if (tipo != T_SPACE) {
            st->contagem[tipo]++;
            st->total++;
            if (mostrar_tokens && (tipo != T_COMMENT || mostrar_comentarios)) {
                printf("%4ld:%-3ld  %-14s  ", linha, coluna, TOKEN_NAME[tipo]);
                imprimir_lexema(src + pos, tam);
                putchar('\n');
            }
        }

        /* ---- avancar o cursor mantendo linha e coluna ---- */
        {
            size_t k;
            for (k = 0; k < tam; k++) {
                if (src[pos + k] == '\n') { linha++; coluna = 1; }
                else                        coluna++;
            }
            pos += tam;
        }
    }
}

static void imprimir_resumo(const Estatisticas *st)
{
    int i;
    printf("\n--- resumo lexico ---\n");
    for (i = 0; i < T_COUNT; i++) {
        if (i == T_SPACE) continue;
        if (st->contagem[i] > 0)
            printf("  %-14s %6ld\n", TOKEN_NAME[i], st->contagem[i]);
    }
    printf("  %-14s %6ld\n", "TOTAL", st->total);
    if (st->erros > 0)
        printf("  %-14s %6ld\n", "erros lexicos", st->erros);
}

static void uso(const char *prog)
{
    printf("uso: %s [opcoes] [arquivo.fs]\n\n", prog);
    printf("Analisador lexico de Forth escrito em C com regex POSIX.\n");
    printf("Sem arquivo, le da entrada padrao.\n\n");
    printf("opcoes:\n");
    printf("  -s   mostra apenas o resumo estatistico\n");
    printf("  -c   omite os comentarios da listagem de tokens\n");
    printf("  -h   mostra esta ajuda\n");
}

int main(int argc, char **argv)
{
    const char *arquivo = NULL;
    int   mostrar_tokens = 1, mostrar_comentarios = 1;
    int   i;
    FILE *f = stdin;
    char *src;
    size_t tamanho;
    Estatisticas st;

    for (i = 1; i < argc; i++) {
        if      (strcmp(argv[i], "-s") == 0) mostrar_tokens = 0;
        else if (strcmp(argv[i], "-c") == 0) mostrar_comentarios = 0;
        else if (strcmp(argv[i], "-h") == 0) { uso(argv[0]); return 0; }
        else if (argv[i][0] == '-' && argv[i][1] != '\0') {
            fprintf(stderr, "opcao desconhecida: %s\n", argv[i]);
            return 1;
        }
        else arquivo = argv[i];
    }

    if (arquivo) {
        f = fopen(arquivo, "rb");
        if (!f) {
            fprintf(stderr, "lexforth: nao consegui abrir '%s'\n", arquivo);
            return 1;
        }
    }

    compilar_regexes();

    src = ler_tudo(f, &tamanho);
    if (arquivo) fclose(f);

    memset(&st, 0, sizeof st);

    if (mostrar_tokens) {
        printf("linha:col  tipo            lexema\n");
        printf("---------------------------------------------------------\n");
    }
    analisar(src, mostrar_tokens, mostrar_comentarios, &st);
    imprimir_resumo(&st);

    free(src);
    liberar_regexes();
    return st.erros > 0 ? 2 : 0;
}
