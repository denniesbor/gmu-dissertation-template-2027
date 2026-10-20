@echo off
rem Build main.pdf on Windows with TeX Live 2026 or MiKTeX.
rem   build            LuaLaTeX (the engine UDTS supplies the template for)
rem   build pdflatex   pdfLaTeX
rem Auxiliary files are written next to the sources. Delete them with: build clean
setlocal
set ENGINE=%1
if "%ENGINE%"=="" set ENGINE=lualatex
if /i "%ENGINE%"=="clean" goto :clean

where %ENGINE% >nul 2>nul || (echo %ENGINE% was not found on PATH. Install TeX Live 2026 or MiKTeX. & exit /b 1)
where bibtex >nul 2>nul || (echo bibtex was not found on PATH. & exit /b 1)
where kpsewhich >nul 2>nul || (echo kpsewhich was not found on PATH. & exit /b 1)
rem preamble/headings.tex needs the heading templates of latex-lab 2026-06-01. The
rem TeX Live 2026 release media stop at LaTeX 2025-11-01; run "tlmgr update --self --all"
rem there. MiKTeX installs the file on first use, so the check is skipped for it.
kpsewhich --version 2>nul | findstr /i miktex >nul && goto :build
set SECTPL=
for /f "delims=" %%p in ('kpsewhich latex-lab-testphase-sec-template.sty 2^>nul') do set SECTPL=%%p
if not defined SECTPL (
  echo LaTeX 2026-06-01 or newer with its latex-lab is required. Run: tlmgr update --self --all
  exit /b 1
)

:build
%ENGINE% -interaction=nonstopmode -file-line-error main.tex >nul || goto :fail
rem BibTeX runs on every auxiliary file that requests a bibliography.
if exist main.aux findstr /m /c:"\bibdata" main.aux >nul && (bibtex main >nul || goto :fail)
for %%f in (chapters\*.aux) do (
  findstr /m /c:"\bibdata" "%%f" >nul && (bibtex "chapters\%%~nf" >nul || goto :fail)
)
rem Run again until the log stops asking for another run (two runs after BibTeX
rem with LuaLaTeX, three with pdfLaTeX).
%ENGINE% -interaction=nonstopmode -file-line-error main.tex >nul || goto :fail
set /a RUNS=2
:rerun
findstr /c:"Rerun to get" main.log >nul || goto :done
if %RUNS% geq 6 (echo cross-references did not settle after %RUNS% runs, see main.log & goto :fail)
%ENGINE% -interaction=nonstopmode -file-line-error main.tex >nul || goto :fail
set /a RUNS+=1
goto :rerun
:done
echo built main.pdf with %ENGINE% (%RUNS% runs)
findstr /c:"Overfull" main.log >nul && echo note: main.log reports overfull lines
exit /b 0

:fail
echo build failed, see main.log and the .blg files in chapters
exit /b 1

:clean
del /q main.aux main.log main.toc main.lof main.lot main.out main.bbl main.blg main.xmpdata 2>nul
del /q chapters\*.aux chapters\*.bbl chapters\*.blg 2>nul
echo removed auxiliary files
exit /b 0
