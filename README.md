# George Mason University dissertation and thesis template, accessible

A LaTeX project for a George Mason University (GMU) dissertation or thesis
on the 2027 accessible template of University Dissertation and Thesis
Services (UDTS): 1.5 line spacing, Fira Sans, no first line indent, and a
tagged PDF (PDF/UA-2). It serves both styles UDTS accepts, the traditional
dissertation with one reference list at the end and the manuscript style
with a reference list after each chapter. It compiles with LuaLaTeX or
pdfLaTeX on Overleaf, Linux, macOS, and Windows.

The university style file `gmuETD.sty` is the September 2026 release from
UDTS, unchanged, with its authors' credits and notices. Everything else in
this project was written around it by Dennies K. Bor, Department of
Geography and Geoinformation Science, for a dissertation that passed the
UDTS format review in October 2026. It is not an official UDTS product.
The [UDTS website](https://udts.gmu.edu/) is the authority on formatting,
and its format review decides whether a document is accepted.

## What is in the project

| Path | Content |
| --- | --- |
| `main.tex` | Root file: the style switch, the front matter order, and the chapter list. |
| `gmuETD.sty` | The UDTS style, unchanged. |
| `preamble/` | Packages, fonts, tagging setup, headings, and the settings that change the style's output (`overrides.tex`). |
| `frontmatter/` | Metadata (title, committee, signature lines) and one file per front matter page and list. |
| `chapters/` | Two example chapters and an appendix. |
| `figures/` | Figure files. |
| `references.bib` | Bibliography. The three example entries are real publications. |
| `Makefile`, `tools/build.sh` | Build on Linux and macOS. |
| `build.bat` | Build on Windows. |
| `LICENSE` | MIT license for the project files, with the exception for `gmuETD.sty`. |

## Choose the style

One line in `main.tex` sets where the reference lists go:

```
\newcommand{\referencelists}{chapter}   % manuscript style: a list after each chapter
\newcommand{\referencelists}{end}       % traditional style: one list after the appendices
```

Every chapter ends with `\chapterreferences`, and `main.tex` has
`\thesisreferences` after the appendices. The switch decides which of the
two prints, and the other prints nothing, so nothing else changes. In
manuscript style a chapter that reproduces a paper opens with the paper's
abstract, as in `chapters/ch1_example.tex`. Delete that section in
traditional style.

## Choose the engine

LuaLaTeX is the engine UDTS supplies the template for. It sets the
mathematics in Fira Math and writes MathML into the PDF, which screen
readers can read. pdfLaTeX gives the same layout with Fira Sans text and
Computer Modern mathematics, and attaches the LaTeX source of each formula
instead of MathML. Both outputs pass the PDF/UA-2 check. XeLaTeX is not
supported. TeX Live 2025 or older lacks the tagging support.

TeX Live 2026 must be updated to the June 2026 LaTeX release or later.
The TeX Live 2026 and MacTeX 2026 release media stop at LaTeX 2025-11-01,
which lacks the heading templates that `preamble/headings.tex` uses, and
such an installation stops with "The template 'hang' of type 'headformat'
is unknown" until it is updated:

```
tlmgr update --self --all        # with sudo for MacTeX
```

`make check` and `build` report an installation that is too old before
compiling, and `preamble/headings.tex` stops with the same advice when
the LaTeX release is too old, on Overleaf included.

## Compile

**Overleaf.** Upload the zip as a new project. In the project menu set
Compiler to LuaLaTeX or pdfLaTeX, TeX Live version to 2026, and Main
document to `main.tex`. Overleaf runs BibTeX for each reference list on
its own. Overleaf has offered TeX Live 2026 since August 2026, and the
author compiled the template there in October 2026.

**Linux and macOS.** Install TeX Live 2026 (MacTeX 2026 on macOS) and
update it as above. The texlive packages of Fedora and Ubuntu are TeX
Live 2023 and do not build the template. A TeX Live under
`~/texlive/2026`, as [install-tl](https://www.tug.org/texlive/quickinstall.html)
makes without root, is used before the one on PATH, so it needs no PATH
change. In a terminal in this folder:

```
make check                     # report the TeX installation and missing packages
make thesis                    # build main.pdf with LuaLaTeX
make thesis ENGINE=pdflatex    # build main.pdf with pdfLaTeX
make clean                     # remove the .build folder
```

**Windows.** Install TeX Live 2026 or MiKTeX. In a command prompt in this
folder:

```
build              build main.pdf with LuaLaTeX
build pdflatex     build main.pdf with pdfLaTeX
build clean        remove the auxiliary files
```

MiKTeX installs missing packages on first use when that option is on.

**By hand.** From this folder, with `pdflatex` in place of `lualatex` if
you prefer. In manuscript style BibTeX runs once per chapter, in
traditional style once on `main`:

```
lualatex main
bibtex chapters/ch1_example    # manuscript style, one line per chapter
bibtex chapters/ch2_example
bibtex main                    # traditional style, this line only
lualatex main
lualatex main
```

**Packages.** A full TeX Live has everything. A smaller one needs these
beyond the basic and latex collections:

```
tlmgr install collection-latexrecommended collection-fontsrecommended \
  adjustbox apacite collectbox ctablestack fira firamath fontaxes \
  fontsetup luamml luatexbase placeins ulem
```

## Files to edit

| File | Content |
| --- | --- |
| `frontmatter/metadata.tex` | Title, your name, degree, program, earlier degrees, director, committee, and the signature lines. Comments explain each setting. |
| `frontmatter/dedication.tex`, `acknowledgments.tex` | Required pages. |
| `frontmatter/disclaimer.tex`, `ai_statement.tex`, `previously_published.tex` | Optional pages. Delete the matching two lines in `main.tex` to drop one. |
| `frontmatter/list_equations.tex`, `list_abbreviations.tex`, `list_symbols.tex` | Optional lists. Delete the matching lines in `main.tex` to drop one. |
| `frontmatter/abstract.tex`, `biography.tex` | Required pages. |
| `chapters/ch1_example.tex` | A chapter with sections, citations, a figure, a table, equations, and its reference list. Copy it for each chapter and add an `\include` line in `main.tex`. |
| `chapters/ch2_example.tex` | A second chapter, showing headings and cross references. |
| `chapters/appendix_a.tex` | An appendix. Delete the three appendix lines in `main.tex` if you have none. |
| `references.bib` | Your bibliography, in BibTeX form. |
| `figures/` | Your figures, as PDF or PNG. Both work with either engine. PDF keeps line drawings sharp, PNG suits photographs and screen captures. EPS files must be converted to PDF first. |

The signature lines after the committee differ by college and program.
Take the names and titles from your college's [signature
sheet](https://library.gmu.edu/udts/SignatureSheets). The example shows
the College of Science PhD sheet of 2026.

## Accessibility

Required for a tagged PDF:

- Every figure has alternative text in the `alt` key of `\includegraphics`,
  as in `chapters/ch1_example.tex`.
- Every table marks its header row with `\tagpdfsetup{table/header-rows={1}}`
  before `\begin{tabular}`, as in the example table.
- Tables use `\hline` for rules. Under pdfLaTeX the booktabs rules are not
  recorded as decoration and fail the PDF/UA check.
- Mathematics is written in standard LaTeX math. Under LuaLaTeX it is
  converted to MathML. Under pdfLaTeX the LaTeX source of each formula is
  attached instead.

The example compiles, in both styles and with either engine, to a PDF
that passes veraPDF 1.30.2 with the PDF/UA-2 profile (0 failed checks). A
screen reader test is still advisable.

## Settings that change the style's output

`gmuETD.sty` is not edited. `preamble/overrides.tex` holds these settings,
each with a comment on how to change or remove it:

| Setting | Why |
| --- | --- |
| Signature page title underlined in capitals. | UDTS requires it. The title is underlined one line at a time, so break it with `\\` in `\title`. |
| "In Partial Fulfillment of" on the signature page. | Matches the UDTS signature sheets. |
| Director's rank on the title page set with `\advisorrank{}`. | The style prints "Professor" for everyone. |
| Copyright page numbered ii. | UDTS requires it. The style numbers it iii. |
| Biography at 1.5 spacing. | UDTS requires it. The style sets it single. |
| Reference lists in APA layout (apacite), per chapter or at the end. | The style's own list numbers its entries. |
| Chapter and front matter headings recorded as PDF headings (`preamble/headings.tex`). | Needed for the tagged PDF. Chapters are numbered "1. Title" as in the template. |
| Signature line spacing reduced (`frontmatter/metadata.tex`). | Seven signature lines fit on one page. Restore the defaults for fewer lines. |
| pdfLaTeX only: the roman family is Fira, `\copyright` is followed by a zero width mark, and `\hline` is marked as decoration (`preamble/fonts.tex`, `preamble/overrides.tex`). | The style switches to the roman family on its title pages. pdfTeX writes the space after the copyright symbol in the symbol font, whose space glyph fails the PDF/UA check, and draws table rules outside the tagged content. |

## Testing on a new computer

After installing TeX Live 2026 (or MiKTeX on Windows), build once with
each engine from this folder and compare with the expected result:

| Step | Expected |
| --- | --- |
| `make check` (Linux, macOS) | Ends with "All required programs and files were found." |
| `make thesis` or `build` | Ends with "built main.pdf". `main.pdf` has 22 pages in manuscript style, 21 in traditional style. |
| `make thesis ENGINE=pdflatex` or `build pdflatex` | Same page counts. Mathematics in Computer Modern. |
| Switch `\referencelists` to `end` and build again | 21 pages, one References heading before the Biography. |
| Open `main.pdf` | Signature page on one sheet with the title underlined, copyright page numbered ii, one References heading after each chapter (manuscript) or one before the Biography (traditional). |
| Optional: [veraPDF](https://verapdf.org/) with the PDF/UA-2 profile | 0 failed checks. |

Please report the operating system, TeX distribution, engine, and the
last lines of `main.log` for any step that differs.

## Tested

Compiled in both styles with LuaHBTeX 1.24.0 and pdfTeX 1.40.29, LaTeX
2026-06-01, TeX Live 2026 on Linux. All four PDFs pass veraPDF 1.30.2
with the PDF/UA-2 profile. Not yet tested on Overleaf, macOS, or Windows.
`build.bat` was written for Windows but has not run there yet.

## License

The project files are released under the MIT license in `LICENSE`,
copyright Dennies K. Bor. `gmuETD.sty` and the example figure are the
property of their authors and George Mason University, included unchanged
with their notices, and are not covered by that license. Permission from
UDTS to redistribute them here has been requested and not yet given.

Source and issues: https://github.com/denniesbor/gmu-dissertation-template-2027
