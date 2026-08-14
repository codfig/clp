# Makefile - analisador lexico de Forth
# Requer um compilador C com <regex.h> POSIX (Cygwin, WSL, Linux ou macOS).
# ATENCAO: MinGW e MSVC nao possuem <regex.h>. Veja o README.txt.

CC      = gcc
CFLAGS  = -std=gnu99 -Wall -Wextra -O2
PROG    = lexforth

.PHONY: all teste erros resumo curso limpo

all: $(PROG)

$(PROG): lexforth.c
	$(CC) $(CFLAGS) -o $(PROG) lexforth.c

# lista todos os tokens do arquivo de exemplo
teste: $(PROG)
	./$(PROG) exemplo.fs

# demonstra a deteccao de erro lexico (sai com codigo 2, por isso o "-")
erros: $(PROG)
	-./$(PROG) erros.fs

# so o resumo estatistico
resumo: $(PROG)
	./$(PROG) -s exemplo.fs

# roda sobre o material de Forth da aula
curso: $(PROG)
	./$(PROG) -s ../forth/exemplos.fs
	./$(PROG) -s ../forth/pratica/pratica.fs

limpo:
	rm -f $(PROG) $(PROG).exe
