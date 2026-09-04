# EXPRESSOES REGULARES COM egrep - PARTE 1: FUNDAMENTOS

Arquivo de dados: dados.txt (mesma pasta)  
Continuacao......: tutorial-grep-parte2.txt

Cada tema traz o conceito, os comandos comentados, caixas CUIDADO no ponto exato onde o erro costuma acontecer, e exercicios. Rode TODOS os comandos: este material foi escrito para ser executado, nao lido.

Os exercicios nao tem gabarito. A conferencia e o proprio arquivo de dados - abra o dados.txt e veja se o resultado faz sentido.

## TEMA 1 - INSTALACAO E PRIMEIRO CONTATO

### LINUX

O grep ja vem instalado em qualquer distribuicao. Confira a versao:

```
grep --version
```

Precisa ser GNU grep 3.x. Se faltar:

```
sudo apt install grep      # Debian, Ubuntu
sudo dnf install grep      # Fedora, RHEL
```

### macOS

O macOS traz o grep do BSD, que NAO e o GNU grep. A diferenca aparece nos temas avancados: o BSD nao tem a opcao -P (PCRE) e trata algumas extensoes de outro jeito. Para acompanhar o material sem surpresas:

```
brew install grep
```

O Homebrew instala como ggrep, para nao substituir o do sistema. Use ggrep no lugar de egrep, ou crie um alias:

```
alias egrep='ggrep -E'
```

### WINDOWS

Use o WSL e siga as instrucoes de Linux. Sem WSL, o Git Bash e o Cygwin trazem o GNU grep, mas atencao: nesses ambientes o "egrep" e um SCRIPT de shell, entao no PowerShell so funciona "grep.exe -E". No Git Bash, funciona normalmente.

### egrep OU grep -E?

Sao o mesmo programa. Versoes recentes avisam que "egrep" esta obsoleto. Este material usa egrep por ser mais curto; se o aviso incomodar, troque por "grep -E" em qualquer comando - o comportamento e identico.

### PRIMEIRO CONTATO

Entre na pasta do material e confirme que os dados estao la:

```
cd aula1/regex
egrep -c '' dados.txt
```

O padrao vazio casa toda linha, entao isso conta as linhas do arquivo.

### EXERCICIOS

- 1.1 Descubra qual grep o seu sistema usa e se e GNU ou BSD.
- 1.2 Conte as linhas de dados.txt e compare com o resultado de "wc -l". Eles batem? Se nao, o que explica a diferenca?
- 1.3 Rode "egrep '' dados.txt" sem o -c. Por que a saida e essa?

## TEMA 2 - BUSCA LITERAL E AS OPCOES ESSENCIAIS

Um padrao sem metacaracteres procura o texto EM QUALQUER POSICAO da linha, e a linha inteira e impressa.

```
egrep 'casa' dados.txt
```

Repare: "casinha" nao aparece, mas "descasar" sim - o padrao esta contido nela.

As opcoes que voce vai usar o tempo todo:

```
-n  numera as linhas          -i  ignora maiusculas/minusculas
-c  conta as linhas que casam -v  inverte (mostra o que NAO casa)
-o  mostra so o trecho que casou   -w  exige palavra inteira
-l  lista so os nomes dos arquivos
-A n / -B n / -C n  mostra n linhas de contexto depois/antes/ambos
--color=auto  pinta o trecho que casou

egrep -n 'casa' dados.txt
egrep -in 'casa' dados.txt
```

O -i pega casa, Casa e CASA de uma vez.

```
egrep -nw 'sub' dados.txt
```

Sem o -w, esse comando traria tambem "substituir", "subir" e "insubstituivel".

```
egrep -n --color=auto 'gato' dados.txt
```

Use --color em todos os exercicios seguintes: ver o trecho pintado dentro da linha ensina mais rapido do que qualquer explicacao.

### CUIDADO - ASPAS SIMPLES

Sempre envolva o padrao em 'aspas simples'. Sem elas o shell interpreta \*, ?, $, | e \ ANTES do egrep ver o padrao. O comando

```
egrep a|b arquivo
```

nao busca "a ou b": o shell entende um PIPE e manda a saida do egrep para um programa chamado "b".

### CUIDADO - -c CONTA LINHAS, NAO OCORRENCIAS

Uma linha com tres "casa" conta 1. Para contar ocorrencias de verdade:

```
egrep -o 'casa' dados.txt | wc -l
```

### EXERCICIOS

- 2.1 Liste as linhas que contem "gato", numeradas, sem diferenciar maiusculas.
- 2.2 Quantas linhas NAO contem a letra "a"?
- 2.3 Conte as ocorrencias da palavra "linha" de duas formas: com -c e com -o | wc -l. Explique a diferenca nos numeros.
- 2.4 Encontre as linhas onde "cat" aparece como palavra isolada, sem casar "concatenar" nem "scatter".
- 2.5 Use --color=auto num padrao que apareca varias vezes na mesma linha. O que a cor revela que a saida normal esconde?

## TEMA 3 - O PONTO: QUALQUER CARACTERE

O "." casa UM caractere qualquer, exceto a quebra de linha.

```
egrep -n 'c.sa' dados.txt
```

Casa "casa", "casarao" e "descasar" - em todas ha um caractere entre o "c" e o "sa".

```
egrep -n 'c...o' dados.txt
```

Tres caracteres quaisquer entre c e o. Isso traz "encaixotar" e "cachorro", mas tambem "conceito" e "usuario@localhost": o ponto nao distingue letra de simbolo.

Para casar um ponto LITERAL, escape com a barra invertida:

```
egrep -n 'ponto.final' dados.txt
egrep -n 'ponto\.final' dados.txt
```

Rode os dois e compare a contagem. O primeiro casa tambem "ponto-final", porque para ele o ponto e um coringa.

### CUIDADO

O "." e o metacaractere mais facil de esquecer. Em "192.168.0.1" o padrao sem escape casaria tambem "192x168y0z1". Em enderecos de IP e nomes de arquivo, escape sempre.

### EXERCICIOS

- 3.1 Escreva um padrao que case qualquer palavra de exatamente 3 letras numa linha so dela.
- 3.2 Encontre as linhas com um "@" cercado por qualquer caractere de cada lado.
- 3.3 Compare "egrep 'e-mail.a@b.c'" com "egrep 'e-mail: a@b\.c'". Por que o primeiro funciona mesmo estando errado?
- 3.4 O padrao '...' (tres pontos) casa quantas linhas? Por que?

## TEMA 4 - CLASSES DE CARACTERES [ ]

Colchetes definem um CONJUNTO: casam um caractere, qualquer um dos listados.

```
egrep -n 'cas[ao]' dados.txt
```

Casa "casa" e "caso", mas nao "casu". Intervalos usam hifen:

```
egrep -n '[0-9]' dados.txt
```

Varios intervalos convivem na mesma classe: [A-Z0-9] e maiuscula OU digito.

```
egrep -n '[A-Z0-9]' dados.txt
```

O acento circunflexo DENTRO dos colchetes nega o conjunto:

```
egrep -n '[^a-zA-Z0-9 .,:_-]' dados.txt
```

Isso encontra as linhas com algum caractere fora do conjunto "comum": pontuacao exotica, parenteses, cifrao.

Dentro da classe os metacaracteres perdem o poder: [.] e um ponto literal, [\*+] sao asterisco e mais literais.

```
egrep -n '[*+]' dados.txt
```

### CUIDADO - A POSICAO DO - E DO ^

Para incluir o hifen no conjunto, ponha-o no FIM: [0-9-]. No comeco, [-0-9] tambem funciona; no meio, ele vira intervalo e o sentido muda. O ^ so nega quando e o PRIMEIRO caractere: [a^] casa "a" ou "^".

### EXERCICIOS

- 4.1 Case as linhas formadas exclusivamente por digitos e hifens.
- 4.2 Encontre as linhas que contem alguma vogal acentuada ou "c" cedilha.
- 4.3 Escreva uma classe que case os separadores de data: barra, hifen e ponto.
- 4.4 Qual a diferenca entre '[^0-9]' e '[0-9]' com a opcao -v? Teste os dois e explique - a resposta nao e "nenhuma".
- 4.5 Encontre as linhas que contem chaves ou colchetes.

## TEMA 5 - ANCORAS ^ E $

Ancoras nao casam caracteres, casam POSICOES.

```
egrep -n '^casa' dados.txt
```

Agora "descasar" some: so interessam as linhas que COMECAM com casa.

```
egrep -n 'fim$' dados.txt
```

O $ faz o simetrico: linhas que TERMINAM com fim.

```
egrep -n '^cat$' dados.txt
```

Os dois juntos exigem que a linha seja EXATAMENTE aquilo.

```
egrep -n '^$' dados.txt
```

Dai sai o idioma para achar linhas vazias: comeco colado no fim.

```
egrep -n ' +$' dados.txt
```

Ancoras sao a ferramenta para cacar espaco invisivel no fim da linha.

### CUIDADO - ARQUIVOS VINDOS DO WINDOWS

Se o arquivo tem quebra de linha CRLF, existe um \r invisivel antes do fim de cada linha, e 'fim$' nao casa nada. Diagnostique e corrija com:

```
egrep -c $'\r' dados.txt
tr -d '\r' < dados.txt > dados-unix.txt
```

### EXERCICIOS

- 5.1 Liste as linhas que comecam com espaco ou TAB.
- 5.2 Quantas linhas do arquivo estao vazias?
- 5.3 Encontre as linhas que comecam E terminam com digito.
- 5.4 Liste as linhas que comecam com --- (os separadores de secao).
- 5.5 Escreva um padrao que case linhas com no maximo 3 caracteres, incluindo a linha vazia.
- 5.6 Por que "egrep '^'" casa todas as linhas, e "egrep '^$'" quase nenhuma?

## TEMA 6 - QUANTIFICADORES \* + ? {n,m}

Um quantificador se aplica ao que vem IMEDIATAMENTE ANTES dele.

```
*      zero ou mais
+      uma ou mais
?      zero ou uma (opcional)
{n}    exatamente n
{n,m}  de n a m
{n,}   n ou mais

egrep -n 'ba*nana' dados.txt
```

Casa "banana" e "bananana" - e casaria "bnana", ja que zero repeticoes servem.

```
egrep -n '^[0-9]+$' dados.txt
```

O + combinado com ancoras da o idioma "a linha inteira e isto".

```
egrep -n '^[+-]?[0-9]+$' dados.txt
```

O ? torna o item opcional: aqui, um sinal antes do numero.

```
egrep -n '[0-9]{4}' dados.txt
egrep -n '^[0-9]{3,5}$' dados.txt
egrep -n '[0-9]{10,}' dados.txt
```

Combinando tudo - numero decimal com parte fracionaria opcional, aceitando ponto ou virgula:

```
egrep -n '^[+-]?[0-9]+([.,][0-9]+)?$' dados.txt
```

### GULOSO

O \* e o + pegam sempre o MAIOR trecho possivel. Compare:

```
egrep -o '".*"' dados.txt
egrep -o '"[^"]*"' dados.txt
```

Numa linha com dois pares de aspas, o primeiro padrao devora do primeiro ao ultimo ", engolindo o texto do meio. O segundo, proibindo aspas dentro do trecho, para na primeira que encontra. Esse truque - negar o proprio delimitador - e a solucao padrao para o problema do guloso.

### CUIDADO - \* CASA ZERO

"egrep '[0-9]\*' arquivo" traz TODAS as linhas, inclusive as sem nenhum digito, porque zero ocorrencias satisfazem o padrao. Quando voce quer "pelo menos um", use +.

### EXERCICIOS

- 6.1 Case as linhas formadas so por letras "a" repetidas.
- 6.2 Encontre os numeros com exatamente 4 digitos, em qualquer posicao.
- 6.3 Escreva um padrao para CEP que aceite 01310-100 e 20040030 - o hifen e opcional.
- 6.4 Case as linhas que contem duas ou mais palavras separadas por espacos multiplos.
- 6.5 Qual a diferenca entre '[0-9]{2,}' e '[0-9][0-9]+'? Teste os dois.
- 6.6 Use -o para extrair todas as sequencias de 2 ou mais espacos consecutivos. Quantas ha?

## TEMA 7 - ALTERNANCIA | E GRUPOS ( )

A barra vertical significa "ou".

```
egrep -n 'gato|rato|pato' dados.txt
```

Parenteses agrupam, evitando repetir a parte comum:

```
egrep -n '(g|r|p)ato' dados.txt
```

Grupo com quantificador repete o GRUPO INTEIRO, nao o ultimo caractere:

```
egrep -n '^(ab)+$' dados.txt
```

Isso casa ab, abab, ababab - e nao casaria "abb".

### PRECEDENCIA

O | tem a MENOR prioridade de todas: sem parenteses, ele separa a expressao INTEIRA. Compare:

```
egrep -n '^inicio|fim$' dados.txt
egrep -n '^(inicio|fim)$' dados.txt
```

O primeiro le-se "comeca com inicio" OU "termina com fim". O segundo exige que a linha seja exatamente uma das duas palavras. E o erro de precedencia mais comum em regex.

### CUIDADO - ERE NAO E BRE

No egrep (que e "grep -E") os parenteses e chaves sao metacaracteres direto: (ab)+ e {2,3}. No grep SEM -E a sintaxe e a antiga, e os mesmos simbolos precisam de barra invertida: \(ab\)\+ e \{2,3\}. Materiais antigos misturam as duas notacoes, e e dai que vem metade da confusao com expressoes regulares.

### EXERCICIOS

- 7.1 Encontre as linhas que contem "sim" ou "nao" como palavra inteira.
- 7.2 Case as linhas que comecam com CPF, CNPJ ou CEP.
- 7.3 Escreva um padrao que case casa, casas, casinha e casarao numa expressao so.
- 7.4 Case linhas formadas pela repeticao do grupo "abc" uma ou mais vezes.
- 7.5 Por que '^a|b$' e '^(a|b)$' dao resultados tao diferentes? Descreva em palavras o que cada um exige.
- 7.6 Escreva um padrao para os protocolos http, https e ftp usando ? em vez de | para um deles.

## FIM DA PARTE 1 - continue em tutorial-grep-parte2.txt
