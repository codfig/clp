# Makefile - analisador lexico de MiniForth
# Requer <regex.h> POSIX: Cygwin, WSL, Linux ou macOS (MinGW/MSVC nao tem).

CC     = gcc
CFLAGS = -std=gnu99 -Wall -Wextra -O2

.PHONY: all teste erros limpo

all: miniforth

miniforth: miniforth.c
	$(CC) $(CFLAGS) -o miniforth miniforth.c

teste: miniforth
	./miniforth exemplo.mf

erros: miniforth
	-./miniforth erros.mf

limpo:
	rm -f miniforth miniforth.exe
