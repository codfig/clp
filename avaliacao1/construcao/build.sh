#!/usr/bin/env bash
# Gera colinha.pdf (A4, 2 colunas, fonte pequena) a partir dos .md de ../topicos.
# Regex + Forth + Lisp ficam nas paginas 1-2; recursao comeca no topo da p. 3.
# Requer pandoc e chromium (snap: o arquivo de saida precisa estar sob $HOME).
# Uso: ./build.sh [tamanho-da-fonte]   ex.: ./build.sh 8.4pt
set -euo pipefail
cd "$(dirname "$0")"
raiz="$(cd .. && pwd)"
topicos="$raiz/topicos"
saida="$raiz/colinha.pdf"
html="$PWD/colinha.html"
font="${1:-}"
{
  printf '<!doctype html><html><head><meta charset="utf-8"><title>Colinha - Avaliação 1</title><style>\n'
  cat colinha.css
  [ -n "$font" ] && printf 'html { font-size: %s; }\n' "$font"
  printf '</style></head><body>\n<div class="cols">\n'
  pandoc "$topicos/regex.md" "$topicos/forth.md" "$topicos/lisp.md" --from gfm --to html5
  printf '</div>\n<div class="cols page">\n'
  pandoc "$topicos/recursao.md" --from gfm --to html5
  printf '</div>\n</body></html>\n'
} > "$html"
chromium-browser --headless=new --no-sandbox --disable-gpu \
  --no-pdf-header-footer --print-to-pdf="$saida" "file://$html" 2>/dev/null
rm "$html"
python3 - "$saida" <<'PY'
import re, sys
d = open(sys.argv[1], 'rb').read()
print('colinha.pdf gerado:', len(re.findall(rb'/Type\s*/Page[^s]', d)), 'paginas,', len(d)//1024, 'KB')
PY
