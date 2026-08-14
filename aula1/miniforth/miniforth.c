/* ===========================================================================
 * miniforth.c - analisador lexico de MiniForth
 * ---------------------------------------------------------------------------
 * MiniForth e um subconjunto minimo de Forth definido para esta aula. Ele tem
 * apenas 4 classes lexicas e 16 palavras reservadas - o suficiente para
 * demonstrar TODOS os problemas centrais de um analisador lexico, e nada mais.
 *
 * Compilar:  gcc -std=gnu99 -Wall -Wextra -O2 -o miniforth miniforth.c
 * Usar:      ./miniforth exemplo.mf
 * ===========================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

enum { ESPACO, COMENTARIO, INTEIRO, CONTROLE, OPERADOR, PALAVRA, ERRO, N_TIPOS };

static const char *NOME[N_TIPOS] = {
    "ESPACO", "COMENTARIO", "INTEIRO", "CONTROLE", "OPERADOR", "PALAVRA", "ERRO"
};

/* --- Fase 1: a FORMA do lexema. A ordem e o algoritmo. ------------------- */
static struct { int tipo; const char *re; int delim; regex_t c; } REGRAS[] = {
    { ESPACO,     "^[ \t\r\n]+",            0, {0} },
    { COMENTARIO, "^\\([ \t\r\n][^)]*\\)",  0, {0} },  /* pode ter varias linhas */
    { INTEIRO,    "^[+-]?[0-9]+",           1, {0} },  /* delim: 12ABC nao e 12 */
    { PALAVRA,    "^[^ \t\r\n]+",           0, {0} },  /* rede de seguranca    */
};

/* --- Fase 2: o SIGNIFICADO da palavra. ---------------------------------- */
static struct { int tipo; const char *re; regex_t c; } CHAVES[] = {
    { CONTROLE, "^(:|;|IF|ELSE|THEN)$", {0} },
    { OPERADOR, "^(\\+|-|\\*|/|DUP|DROP|SWAP|OVER|@|!|\\.|CR)$", {0} },
};

#define N(v) ((int)(sizeof(v) / sizeof((v)[0])))

static void compila(void)
{
    int i;
    for (i = 0; i < N(REGRAS); i++)
        if (regcomp(&REGRAS[i].c, REGRAS[i].re, REG_EXTENDED | REG_ICASE))
            { fprintf(stderr, "regex ruim: %s\n", REGRAS[i].re); exit(1); }
    for (i = 0; i < N(CHAVES); i++)
        if (regcomp(&CHAVES[i].c, CHAVES[i].re, REG_EXTENDED | REG_ICASE))
            { fprintf(stderr, "regex ruim: %s\n", CHAVES[i].re); exit(1); }
}

static int delimitador(char c)
{
    return c == '\0' || c == ' ' || c == '\t' || c == '\r' || c == '\n';
}

/* Uma PALAVRA e reservada? Decidido por regex ancorada em ^...$ */
static int classifica(const char *s, size_t n)
{
    char buf[64];
    int  i;

    if (n >= sizeof buf) return PALAVRA;      /* longa demais para ser chave */
    memcpy(buf, s, n);
    buf[n] = '\0';
    for (i = 0; i < N(CHAVES); i++)
        if (regexec(&CHAVES[i].c, buf, 0, NULL, 0) == 0)
            return CHAVES[i].tipo;
    return PALAVRA;
}

static void mostra(const char *s, size_t n)
{
    size_t i;
    putchar('"');
    for (i = 0; i < n && i < 40; i++)
        if (s[i] == '\n')      fputs("\\n", stdout);
        else if (s[i] != '\r') putchar(s[i]);
    fputs(n > 40 ? "...\"" : "\"", stdout);
}

static char *le(const char *nome)
{
    FILE *f = nome ? fopen(nome, "rb") : stdin;
    size_t cap = 1 << 16, n = 0, r;
    char  *b;

    if (!f) { fprintf(stderr, "nao abri '%s'\n", nome); exit(1); }
    b = malloc(cap);
    while ((r = fread(b + n, 1, cap - n - 1, f)) > 0)
        if ((n += r) + 1 >= cap) b = realloc(b, cap *= 2);
    b[n] = '\0';
    if (nome) fclose(f);
    return b;
}

int main(int argc, char **argv)
{
    const char *arquivo = argc > 1 ? argv[1] : NULL;
    char  *src;
    size_t pos = 0;
    long   linha = 1, coluna = 1, conta[N_TIPOS] = {0}, erros = 0;

    compila();
    src = le(arquivo);
    printf("linha:col  tipo         lexema\n---------------------------------------\n");

    while (src[pos]) {
        regmatch_t m;
        int    i, tipo = ERRO;
        size_t tam = 1;

        /* Fase 1: primeira regra que casar no cursor vence. */
        for (i = 0; i < N(REGRAS); i++) {
            if (regexec(&REGRAS[i].c, src + pos, 1, &m, 0) || m.rm_so != 0)
                continue;
            /* ERE nao tem lookahead: a fronteira do numero e checada aqui. */
            if (REGRAS[i].delim && !delimitador(src[pos + m.rm_eo]))
                continue;
            tipo = REGRAS[i].tipo;
            tam  = (size_t)m.rm_eo;
            break;
        }

        /* Erro lexico: abriu comentario e nunca fechou. */
        if (tipo == PALAVRA && src[pos] == '(' && delimitador(src[pos + 1])) {
            fprintf(stderr, "%ld:%ld: comentario '(' sem ')'\n", linha, coluna);
            tipo = ERRO;
            tam  = strcspn(src + pos, "\n");   /* recupera na proxima linha */
            erros++;
        }

        /* Fase 2: so palavras precisam ser classificadas. */
        if (tipo == PALAVRA)
            tipo = classifica(src + pos, tam);

        if (tipo != ESPACO) {
            conta[tipo]++;
            printf("%4ld:%-3ld  %-11s  ", linha, coluna, NOME[tipo]);
            mostra(src + pos, tam);
            putchar('\n');
        }

        for (i = 0; i < (int)tam; i++)
            if (src[pos + i] == '\n') { linha++; coluna = 1; } else coluna++;
        pos += tam;
    }

    printf("\n--- resumo ---\n");
    for (int i = 0; i < N_TIPOS; i++)
        if (i != ESPACO && conta[i])
            printf("  %-11s %4ld\n", NOME[i], conta[i]);

    free(src);
    return erros ? 2 : 0;
}
