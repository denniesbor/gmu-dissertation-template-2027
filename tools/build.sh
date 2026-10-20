#!/usr/bin/env bash
# Local build. All output goes to .build. The chapter list comes from the \include
# lines in main.tex. A chapter whose bibliography fails stops the build.
# Written for bash 3.2, the version that ships with macOS.
set -euo pipefail

# Use the TeX Live named by THESIS_TEXLIVE when it exists, otherwise the one on PATH.
TLROOT="${THESIS_TEXLIVE:-$HOME/texlive/2026}"
for d in "$TLROOT"/bin/*; do
  if [ -x "$d/lualatex" ]; then PATH="$d:$PATH"; break; fi
done
export PATH

JOB="${1:-main}"
ENGINE="${ENGINE:-lualatex}"
OUT=.build
ROOT="$PWD"
# preamble/headings.tex uses the heading templates of latex-lab 2026-06-01. The
# TeX Live 2026 release media stop at LaTeX 2025-11-01 and need "tlmgr update".
REQUIRED_LATEX="2026-06-01"
TESTED_LATEX="2026-06-01"
MAXRUNS=6
fail() { echo "build_thesis: $*" >&2; exit 1; }

check() {
  local missing=0 tmp ver
  for b in lualatex pdflatex bibtex kpsewhich; do
    if command -v "$b" > /dev/null; then echo "found   $b: $(command -v "$b")"
    else echo "MISSING $b"; missing=1; fi
  done
  [ "$missing" -eq 0 ] || fail "install TeX Live 2026 or put its bin directory on PATH"
  echo "engine  $(lualatex --version | head -n 1)"
  tmp="$(mktemp -d)"
  ver="$(cd "$tmp" && lualatex -interaction=nonstopmode '\typeout{LATEXFORMAT \fmtversion}\stop' 2>/dev/null \
    | sed -n 's/^LATEXFORMAT //p' | head -n 1)"
  rm -rf "$tmp"
  echo "LaTeX   ${ver:-unknown} (required $REQUIRED_LATEX, tested with $TESTED_LATEX)"
  if [ -n "$ver" ] && [[ "$ver" < "$REQUIRED_LATEX" ]]; then
    fail "LaTeX $ver is older than $REQUIRED_LATEX. Install TeX Live 2026 and run 'tlmgr update --self --all' (with sudo for MacTeX)"
  fi
  if [ -n "$ver" ] && [[ "$ver" < "$TESTED_LATEX" ]]; then
    echo "WARNING LaTeX $ver is older than the tested release $TESTED_LATEX."
  fi
  for f in latex-lab-testphase-sec-template.sty \
           apacite.sty apacite.bst chapterbib.sty fontsetup.sty FiraSans-Regular.otf \
           FiraMath-Regular.otf unicode-math.sty luamml.sty FiraSans.sty FiraMono.sty fontaxes.sty adjustbox.sty placeins.sty \
           ulem.sty setspace.sty pdfpages.sty booktabs.sty float.sty eso-pic.sty \
           pdflscape.sty xcolor.sty; do
    if [ -n "$(kpsewhich "$f")" ]; then echo "found   $f"
    else echo "MISSING $f"; missing=1; fi
  done
  [ "$missing" -eq 0 ] || fail "missing TeX files, see README.md for the tlmgr command"
  echo "All required programs and files were found."
}

if [ "$JOB" = "--check" ]; then check; exit 0; fi
command -v "$ENGINE" > /dev/null || fail "$ENGINE not found, run 'make check'"

CHAPTERS=()
while IFS= read -r ch; do CHAPTERS+=("$ch"); done \
  < <(sed -n 's/^\\include{\([^}]*\)}.*/\1/p' main.tex)
[ "${#CHAPTERS[@]}" -gt 0 ] || fail "no \\include lines found in main.tex"
# BibTeX runs on every auxiliary file that requests a bibliography: the chapters
# in manuscript style, main in traditional style.
for ch in "${CHAPTERS[@]}"; do mkdir -p "$OUT/$(dirname "$ch")"; done

run() {
  "$ENGINE" -interaction=nonstopmode -file-line-error -halt-on-error \
    -output-directory="$OUT" -jobname="$JOB" main.tex > /dev/null \
    || fail "$ENGINE failed, see $OUT/$JOB.log"
}
run
NBIB=0
for ch in main "${CHAPTERS[@]}"; do
  aux="$OUT/$ch.aux"
  [ -f "$aux" ] || fail "missing $aux"
  grep -q '\\bibdata' "$aux" || continue
  NBIB=$((NBIB+1))
  # BibTeX will not write to a path that starts with a dot, so it runs inside $OUT.
  ( cd "$OUT" && BIBINPUTS="$ROOT:${BIBINPUTS:-}" bibtex "$ch" > /dev/null ) \
    || fail "bibtex failed on $aux"
  if grep -q -E '^Warning--|error message' "${aux%.aux}.blg"; then
    fail "bibtex reported problems, see ${aux%.aux}.blg"
  fi
  [ -s "${aux%.aux}.bbl" ] || fail "empty bibliography ${aux%.aux}.bbl"
done
[ "$NBIB" -gt 0 ] || fail "no auxiliary file requests a bibliography"
# Run again until the log stops asking for another run. Cross-references,
# outlines, and page labels settle after two runs with LuaLaTeX and three
# with pdfLaTeX.
run
RUNS=2
while grep -q 'Rerun to get' "$OUT/$JOB.log"; do
  [ "$RUNS" -lt "$MAXRUNS" ] || fail "cross-references did not settle after $MAXRUNS runs, see $OUT/$JOB.log"
  run
  RUNS=$((RUNS+1))
done
cp "$OUT/$JOB.pdf" "$JOB.pdf"
echo "built $JOB.pdf with $ENGINE ($NBIB reference lists, $RUNS runs, logs in $OUT)"
