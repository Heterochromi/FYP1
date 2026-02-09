%% fypStandard.cls
%% LaTeX Document Class for MMU FCI Final Year Project Reports
%% Based on the FYP Handbook (Revised APR 2025)
%% Faculty of Computing and Informatics, Multimedia University
%%
%% Designed for use with Quarto (Pandoc → XeLaTeX pipeline)
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{fypStandard}[2025/04/01 MMU FCI FYP Report Class v2.0]

%% --------------------------------------------------------------------------
%% 1. BASE CLASS
%% --------------------------------------------------------------------------
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions\relax
\LoadClass[a4paper,12pt,oneside]{report}

%% --------------------------------------------------------------------------
%% 2. REQUIRED PACKAGES
%% --------------------------------------------------------------------------

% Geometry: margins per handbook
%   Left: 38mm, Right: 28mm, Top: 28mm, Bottom: 28mm
\RequirePackage[
  a4paper,
  left=38mm,
  right=28mm,
  top=28mm,
  bottom=28mm,
  footskip=15mm
]{geometry}

% Conditional logic
\RequirePackage{iftex}
\RequirePackage{etoolbox}
\RequirePackage{ifthen}
\RequirePackage{xstring}

% Line spacing: 1.5 spacing for body text
\RequirePackage{setspace}
\onehalfspacing

% Graphics and floats
\RequirePackage{graphicx}
\RequirePackage{float}

% We do NOT load caption/subcaption here — Quarto/Pandoc will load them.
% We configure them in \AtBeginDocument instead to avoid option clashes.

% Table support
\RequirePackage{booktabs}
\RequirePackage{longtable}
\RequirePackage{array}

% Colours
\RequirePackage{xcolor}

% For title-case and string manipulation
\RequirePackage{textcase}

% Page headers and footers
\RequirePackage{fancyhdr}

% For TOC/LOF/LOT customisation
\RequirePackage{tocloft}

% For appendix handling
\RequirePackage[toc,page]{appendix}

% For embedding external PDF pages (Turnitin reports, meeting logs, Gantt charts, etc.)
\RequirePackage{pdfpages}

% For justified text
\RequirePackage{ragged2e}

% Heading formatting
\RequirePackage{titlesec}

% Hyperref will be loaded by Pandoc; we configure it in \AtBeginDocument.

%% --------------------------------------------------------------------------
%% 3. PAGE NUMBERING AND HEADERS/FOOTERS
%% --------------------------------------------------------------------------
%% Page numbers: bottom centre, every page except title page.
%% Preliminary pages: lowercase roman. Main text: arabic.

\fancypagestyle{plain}{%
  \fancyhf{}%
  \fancyfoot[C]{\thepage}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

\fancypagestyle{fypstyle}{%
  \fancyhf{}%
  \fancyfoot[C]{\thepage}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

\pagestyle{fypstyle}

%% --------------------------------------------------------------------------
%% 4. CHAPTER AND SECTION HEADING FORMATS
%% --------------------------------------------------------------------------
%% Chapter heading: Arial 14pt Bold (we set font in AtBeginDocument)
%% Sub-heading: Arial 12pt Bold
%% Sub-sub-heading: Arial 12pt Bold

% Chapter: 14pt Bold, centred, "CHAPTER X: Title" on one line
\titleformat{\chapter}[block]
  {\normalfont\fontsize{14}{16.8}\bfseries\centering}
  {\MakeUppercase{\chaptertitlename}\ \thechapter:}
  {0.4em}
  {\fontsize{14}{16.8}\bfseries}

\titlespacing*{\chapter}{0pt}{-20pt}{20pt}

% Section (sub-heading): 12pt Bold
\titleformat{\section}
  {\normalfont\fontsize{12}{14.4}\bfseries}
  {\thesection}
  {1em}
  {}

\titlespacing*{\section}{0pt}{12pt}{6pt}

% Subsection (sub-sub-heading): 12pt Bold
\titleformat{\subsection}
  {\normalfont\fontsize{12}{14.4}\bfseries}
  {\thesubsection}
  {1em}
  {}

\titlespacing*{\subsection}{0pt}{12pt}{6pt}

% Subsubsection: 12pt Bold (same as sub-sub per handbook)
\titleformat{\subsubsection}
  {\normalfont\fontsize{12}{14.4}\bfseries}
  {\thesubsubsection}
  {1em}
  {}

\titlespacing*{\subsubsection}{0pt}{12pt}{6pt}

%% --------------------------------------------------------------------------
%% 5. FIGURE AND TABLE NUMBERING
%% --------------------------------------------------------------------------
%% Numbering scheme: chapter.sequential (e.g., Figure 1.2, Table 3.1)

% Reset counters per chapter
\counterwithin{figure}{chapter}
\counterwithin{table}{chapter}
\counterwithin{equation}{chapter}

%% --------------------------------------------------------------------------
%% 6. TABLE OF CONTENTS / LIST OF FIGURES / LIST OF TABLES FORMATTING
%% --------------------------------------------------------------------------

\renewcommand{\contentsname}{TABLE OF CONTENTS}
\renewcommand{\listfigurename}{LIST OF FIGURES}
\renewcommand{\listtablename}{LIST OF TABLES}

% Format TOC entries
\renewcommand{\cftchapfont}{\normalfont\bfseries}
\renewcommand{\cftchappagefont}{\normalfont\bfseries}
\renewcommand{\cftsecfont}{\normalfont}
\renewcommand{\cftsecpagefont}{\normalfont}
\renewcommand{\cftsubsecfont}{\normalfont}
\renewcommand{\cftsubsecpagefont}{\normalfont}

% Dot leaders for all levels
\renewcommand{\cftchapleader}{\cftdotfill{\cftdotsep}}
\renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}}
\renewcommand{\cftsubsecleader}{\cftdotfill{\cftdotsep}}

% Depth of numbering and TOC
\setcounter{secnumdepth}{4}
\setcounter{tocdepth}{3}

%% --------------------------------------------------------------------------
%% 7. CUSTOM VARIABLES (set from Quarto YAML via header-includes or metadata)
%% --------------------------------------------------------------------------

\newcommand{\projectid}[1]{\gdef\@projectid{#1}}
\newcommand{\projecttitle}[1]{\gdef\@projecttitle{#1}}
\newcommand{\studentid}[1]{\gdef\@studentid{#1}}
\newcommand{\studentname}[1]{\gdef\@studentname{#1}}
\newcommand{\programme}[1]{\gdef\@programme{#1}}
\newcommand{\submissionmonthyear}[1]{\gdef\@submissionmonthyear{#1}}
\newcommand{\submissionyear}[1]{\gdef\@submissionyear{#1}}
\newcommand{\reporttype}[1]{\gdef\@reporttype{#1}}
\newcommand{\degreename}[1]{\gdef\@degreename{#1}}
\newcommand{\supervisorname}[1]{\gdef\@supervisorname{#1}}
\newcommand{\logopath}[1]{\gdef\@logopath{#1}}

% Default logo path
\gdef\@logopath{logo.png}

% Defaults
\gdef\@projectid{FYP01-IS-T2510-0001}
\gdef\@projecttitle{Project Title}
\gdef\@studentid{1234567890}
\gdef\@studentname{STUDENT NAME}
\gdef\@programme{BACHELOR OF INFORMATION TECHNOLOGY}
\gdef\@submissionmonthyear{MONTH YEAR}
\gdef\@submissionyear{2026}
\gdef\@reporttype{INTERIM}
\gdef\@degreename{BACHELOR OF INFORMATION TECHNOLOGY}
\gdef\@supervisorname{Supervisor Name}

%% --------------------------------------------------------------------------
%% 8. COVER PAGE
%% --------------------------------------------------------------------------
\newcommand{\makecoverpage}{%
  \begin{titlepage}
    \thispagestyle{empty}
    \begin{center}
      \vspace*{-0.5cm}
      \includegraphics[width=0.65\textwidth]{\@logopath}\\[1.5cm]
      {\fontsize{14}{16.8}\selectfont\bfseries
        FINAL YEAR PROJECT \MakeUppercase{\@reporttype} REPORT}\\[2cm]
      {\fontsize{14}{16.8}\selectfont\bfseries \@projectid}\\[0.5cm]
      {\fontsize{14}{16.8}\selectfont\bfseries \MakeUppercase{\@projecttitle}}\\
      \vfill
      {\fontsize{14}{16.8}\selectfont\bfseries \@studentid}\\[0.5cm]
      {\fontsize{14}{16.8}\selectfont\bfseries \MakeUppercase{\@studentname}}\\
      \vfill
      {\fontsize{14}{16.8}\selectfont\bfseries \MakeUppercase{\@programme}}\\[1cm]
      {\fontsize{14}{16.8}\selectfont\bfseries \MakeUppercase{\@submissionmonthyear}}\\
      \vspace*{1cm}
    \end{center}
  \end{titlepage}
  \setcounter{page}{1}%  Title page is page "i" but not displayed
}

%% --------------------------------------------------------------------------
%% 9. TITLE PAGE
%% --------------------------------------------------------------------------
\newcommand{\maketitlepage}{%
  \begin{titlepage}
    \thispagestyle{empty}
    \begin{center}
      \vspace*{1cm}
      {\fontsize{14}{16.8}\selectfont\bfseries \@projectid}\\[0.5cm]
      {\fontsize{14}{16.8}\selectfont\bfseries \MakeUppercase{\@projecttitle}}\\
      \vfill
      {\fontsize{12}{14.4}\selectfont\bfseries BY}\\[1cm]
      {\fontsize{12}{14.4}\selectfont\bfseries \@studentid\quad \MakeUppercase{\@studentname}}\\
      \vfill
      {\fontsize{12}{14.4}\selectfont
        PROJECT \MakeUppercase{\@reporttype} REPORT SUBMITTED IN PARTIAL FULFILMENT OF THE}\\[0.3cm]
      {\fontsize{12}{14.4}\selectfont REQUIREMENT FOR THE DEGREE OF}\\[0.5cm]
      {\fontsize{12}{14.4}\selectfont\bfseries \MakeUppercase{\@degreename}}\\[1cm]
      {\fontsize{12}{14.4}\selectfont in the}\\[0.5cm]
      {\fontsize{12}{14.4}\selectfont Faculty of Computing and Informatics}\\[2cm]
      {\fontsize{14}{16.8}\selectfont\bfseries MULTIMEDIA UNIVERSITY}\\[0.3cm]
      {\fontsize{14}{16.8}\selectfont\bfseries MALAYSIA}\\[1.5cm]
      {\fontsize{12}{14.4}\selectfont \@submissionmonthyear}\\
      \vspace*{1cm}
    \end{center}
  \end{titlepage}
}

%% --------------------------------------------------------------------------
%% 10. COPYRIGHT PAGE
%% --------------------------------------------------------------------------
\newcommand{\makecopyrightpage}{%
  \clearpage
  \thispagestyle{plain}
  \vspace*{3cm}
  \begin{center}
    {\normalsize \textcopyright\ \@submissionyear\ Universiti Telekom Sdn.\ Bhd.\ ALL RIGHTS RESERVED.}
  \end{center}
  \vspace{2cm}
  \noindent
  Copyright of this report belongs to Universiti Telekom Sdn.\ Bhd.\ as qualified by
  Regulation 7.2 (c) of the Multimedia University Intellectual Property and
  Commercialisation Policy. No part of this publication may be reproduced, stored in or
  introduced into a retrieval system, or transmitted in any form or by any means (electronic,
  mechanical, photocopying, recording, or otherwise), or for any purpose, without the
  express written permission of Universiti Telekom Sdn.\ Bhd.\ Due acknowledgement shall
  always be made of the use of any material contained in, or derived from, this report.
  \clearpage
}

%% --------------------------------------------------------------------------
%% 11. DECLARATION PAGE
%% --------------------------------------------------------------------------
\newcommand{\makedeclarationpage}{%
  \clearpage
  \thispagestyle{plain}
  \begin{center}
    {\fontsize{14}{16.8}\selectfont\bfseries DECLARATION}
  \end{center}
  \vspace{2cm}
  \noindent
  I hereby declare that the work has been done by myself and no portion of the work
  contained in this report has been submitted in support of any application for any other
  degree or qualification of this or any other university or institution of learning.
  \vspace{4cm}

  \noindent
  \begin{tabular}{@{}l}
    \rule{8cm}{0.4pt} \\
    Name of candidate: \MakeUppercase{\@studentname} \\
    Faculty of Computing \& Informatics \\
    Multimedia University \\
    Date: \underline{\hspace{4cm}}
  \end{tabular}
  \clearpage
}

%% --------------------------------------------------------------------------
%% 12. ACKNOWLEDGEMENTS ENVIRONMENT
%% --------------------------------------------------------------------------
\newenvironment{acknowledgements}{%
  \clearpage
  \thispagestyle{plain}
  \begin{center}
    {\fontsize{14}{16.8}\selectfont\bfseries ACKNOWLEDGEMENTS}
  \end{center}
  \vspace{1cm}
  \noindent
}{%
  \clearpage
}

%% --------------------------------------------------------------------------
%% 13. ABSTRACT ENVIRONMENT
%% --------------------------------------------------------------------------
\renewenvironment{abstract}{%
  \clearpage
  \thispagestyle{plain}
  \begin{center}
    {\fontsize{14}{16.8}\selectfont\bfseries ABSTRACT}
  \end{center}
  \vspace{1cm}
  \noindent
}{%
  \clearpage
}

%% --------------------------------------------------------------------------
%% 14. LIST OF ABBREVIATIONS ENVIRONMENT
%% --------------------------------------------------------------------------
\newenvironment{listofabbreviations}{%
  \clearpage
  \thispagestyle{plain}
  \begin{center}
    {\fontsize{14}{16.8}\selectfont\bfseries LIST OF ABBREVIATIONS / SYMBOLS}
  \end{center}
  \addcontentsline{toc}{chapter}{LIST OF ABBREVIATIONS / SYMBOLS}
  \vspace{1cm}
}{%
  \clearpage
}

%% --------------------------------------------------------------------------
%% 15. LIST OF APPENDICES ENVIRONMENT
%% --------------------------------------------------------------------------
\newenvironment{listofappendices}{%
  \clearpage
  \thispagestyle{plain}
  \begin{center}
    {\fontsize{14}{16.8}\selectfont\bfseries LIST OF APPENDICES}
  \end{center}
  \addcontentsline{toc}{chapter}{LIST OF APPENDICES}
  \vspace{1cm}
}{%
  \clearpage
}

%% --------------------------------------------------------------------------
%% 16. PRELIMINARY PAGES COMMAND (roman numbering)
%% --------------------------------------------------------------------------
\newcommand{\frontmatteraliased}{%
  \clearpage
  \pagenumbering{roman}%
  \setcounter{page}{2}%  Cover/title is "i" but not shown; first displayed prelim page is "ii"
}

%% --------------------------------------------------------------------------
%% 17. MAIN MATTER COMMAND (arabic numbering)
%% --------------------------------------------------------------------------
\newcommand{\mainmatteraliased}{%
  \clearpage
  \pagenumbering{arabic}%
  \setcounter{page}{1}%
}

%% --------------------------------------------------------------------------
%% 18. BLOCK QUOTATION FORMATTING (for quotations over 40 words)
%% --------------------------------------------------------------------------
\renewenvironment{quote}{%
  \list{}{%
    \leftmargin=12.7mm
    \rightmargin=0mm
    \topsep=6pt
    \parsep=0pt
  }%
  \item\relax
  \doublespacing
}{%
  \endlist
  \onehalfspacing
}

%% --------------------------------------------------------------------------
%% 19. SINGLE SPACING INSIDE TABLES
%% --------------------------------------------------------------------------
\AtBeginEnvironment{tabular}{\singlespacing}
\AtBeginEnvironment{longtable}{\singlespacing}

%% --------------------------------------------------------------------------
%% 20. AtBeginDocument — FIX PANDOC/QUARTO OVERRIDES
%% --------------------------------------------------------------------------
%% Pandoc loads parskip (zeroes \parindent), lmodern (overrides fonts),
%% and sets hyperref colours. We must restore our handbook settings LAST
%% so they take effect.
%%
%% We use \AddToHook{begindocument/end} which fires at the very end of
%% \begin{document}, after all other \AtBeginDocument hooks (including
%% Pandoc's). For older LaTeX kernels we fall back to \AtBeginDocument
%% with \AtEndPreamble as a secondary hook.
%% --------------------------------------------------------------------------

\AddToHook{begindocument/end}{%
  %% ---- Restore paragraph indentation (parskip package zeroed it) ----
  \setlength{\parindent}{12.7mm}%
  %% ---- Restore paragraph skip ----
  \setlength{\parskip}{0pt}%
  %% ---- Restore font to Arial / Helvetica / TeX Gyre Heros ----
  \ifxetex
    \IfFontExistsTF{Arial}{%
      \setmainfont{Arial}%
    }{%
      \IfFontExistsTF{Helvetica}{%
        \setmainfont{Helvetica}%
      }{%
        \IfFontExistsTF{TeX Gyre Heros}{%
          \setmainfont{TeX Gyre Heros}%
        }{}%
      }%
    }%
  \else\ifluatex
    \IfFontExistsTF{Arial}{%
      \setmainfont{Arial}%
    }{%
      \IfFontExistsTF{Helvetica}{%
        \setmainfont{Helvetica}%
      }{%
        \IfFontExistsTF{TeX Gyre Heros}{%
          \setmainfont{TeX Gyre Heros}%
        }{}%
      }%
    }%
  \else
    % pdfLaTeX: helvet is already loaded via the class; just force sf default
    \renewcommand{\familydefault}{\sfdefault}%
  \fi\fi
  %% ---- Restore hyperref settings for formal report (no coloured links) ----
  \hypersetup{%
    colorlinks=false,%
    linkcolor=black,%
    citecolor=black,%
    urlcolor=black,%
    filecolor=black,%
    pdfborder={0 0 0},%
    breaklinks=true%
  }%
  %% ---- Re-assert TOC/LOF/LOT names per handbook ----
  \renewcommand{\contentsname}{TABLE OF CONTENTS}%
  \renewcommand{\listfigurename}{LIST OF FIGURES}%
  \renewcommand{\listtablename}{LIST OF TABLES}%
  %% ---- Justified text and allow sloppy line breaks ----
  \justifying
  \sloppy
}

%% --------------------------------------------------------------------------
%% 21. CAPTION CONFIGURATION (deferred to avoid option clashes with Pandoc)
%% --------------------------------------------------------------------------
\AtBeginDocument{%
  \@ifpackageloaded{caption}{%
    \captionsetup[figure]{%
      labelsep=colon,
      justification=centering,
      font={normalsize},
      labelfont={bf},
      position=below,
      skip=6pt
    }%
    \captionsetup[table]{%
      labelsep=colon,
      justification=centering,
      font={normalsize},
      labelfont={bf},
      position=above,
      skip=6pt
    }%
  }{}%
}

%% --------------------------------------------------------------------------
%% 22. FONT SETUP (initial — may be overridden by Pandoc, restored above)
%% --------------------------------------------------------------------------
%% We attempt an initial font setup here. If Pandoc/lmodern overrides it,
%% the \AddToHook{begindocument/end} block above will re-apply it.
\ifxetex
  \RequirePackage{fontspec}
  \defaultfontfeatures{Ligatures=TeX}
  \IfFontExistsTF{Arial}{%
    \setmainfont{Arial}%
  }{%
    \IfFontExistsTF{Helvetica}{%
      \setmainfont{Helvetica}%
    }{%
      \IfFontExistsTF{TeX Gyre Heros}{%
        \setmainfont{TeX Gyre Heros}%
      }{}%
    }%
  }
\else\ifluatex
  \RequirePackage{fontspec}
  \defaultfontfeatures{Ligatures=TeX}
  \IfFontExistsTF{Arial}{%
    \setmainfont{Arial}%
  }{%
    \IfFontExistsTF{Helvetica}{%
      \setmainfont{Helvetica}%
    }{%
      \IfFontExistsTF{TeX Gyre Heros}{%
        \setmainfont{TeX Gyre Heros}%
      }{}%
    }%
  }
\else
  % pdfLaTeX fallback: Helvetica (closest to Arial)
  \RequirePackage[T1]{fontenc}
  \RequirePackage{helvet}
  \renewcommand{\familydefault}{\sfdefault}
\fi\fi

%% --------------------------------------------------------------------------
%% End of fypStandard.cls
%% --------------------------------------------------------------------------
\endinput
