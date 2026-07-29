#!/usr/bin/env bash
# Export Harvard CV Markdown → PDF (ATS-friendly) via Pandoc + WeasyPrint
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${ROOT}/export"
CSS="${ROOT}/styles/harvard.css"
TEMPLATE="${ROOT}/styles/harvard.html"
ENGINE="${PDF_ENGINE:-weasyprint}"

mkdir -p "${OUT_DIR}"

export_one() {
  local src="$1"
  local lang="$2"
  local base
  base="$(basename "${src}" .md)"
  local pdf="${OUT_DIR}/${base}.pdf"
  local html="${OUT_DIR}/${base}.html"

  echo "→ Generando ${base}.pdf (${lang})..."

  pandoc "${src}" \
    --from markdown \
    --to html5 \
    --standalone \
    --template="${TEMPLATE}" \
    --css="${CSS}" \
    --metadata "lang=${lang}" \
    --embed-resources \
    --output="${html}"

  if [[ "${ENGINE}" == "weasyprint" ]]; then
    weasyprint "${html}" "${pdf}"
    rm -f "${html}"
  else
    pandoc "${src}" \
      --from markdown \
      --pdf-engine=xelatex \
      -V geometry:margin=0.65in \
      -V fontsize=10pt \
      -V documentclass=article \
      -V mainfont="Times New Roman" \
      --output="${pdf}"
  fi

  echo "  OK: ${pdf}"
}

case "${1:-all}" in
  es|ES)
    export_one "${ROOT}/CV_URIARTE_CESAR_ES.md" "es"
    ;;
  en|EN)
    export_one "${ROOT}/CV_URIARTE_CESAR_EN.md" "en"
    ;;
  all|*)
    export_one "${ROOT}/CV_URIARTE_CESAR_ES.md" "es"
    export_one "${ROOT}/CV_URIARTE_CESAR_EN.md" "en"
    ;;
esac

echo
echo "PDFs listos en: ${OUT_DIR}"
ls -la "${OUT_DIR}"/*.pdf
