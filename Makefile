# Local build of the GMU dissertation template (LuaLaTeX, TeX Live 2026). Overleaf does not use this file.
#
#   make            show this help
#   make check      report the TeX installation and any missing packages
#   make thesis     build main.pdf with LuaLaTeX
#   make thesis ENGINE=pdflatex   build with pdfLaTeX
#   make clean      remove .build, keep the PDF
#
# Requirements: TeX Live 2026 with LuaLaTeX and BibTeX, plus make and bash.
# README.md lists the TeX packages and gives the commands for Windows.
#
# The TeX Live in ~/texlive/2026 is used when present, otherwise the one
# on PATH. Point to another installation with
#   make thesis THESIS_TEXLIVE=/usr/local/texlive/2026

THESIS_TEXLIVE ?= $(HOME)/texlive/2026
ENGINE ?= lualatex

.PHONY: help check thesis clean

help:
	@sed -n '1,/^$$/p' Makefile | sed -e 's/^# \{0,1\}//'

check:
	@THESIS_TEXLIVE="$(THESIS_TEXLIVE)" bash tools/build.sh --check

thesis:
	THESIS_TEXLIVE="$(THESIS_TEXLIVE)" ENGINE="$(ENGINE)" bash tools/build.sh main

clean:
	rm -rf .build
