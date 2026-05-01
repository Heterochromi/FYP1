#let mmu-blue = rgb(70, 80, 164)

#let article(
  title: none,
  project-id: none,
  student-id: none,
  student-name: none,
  programme: none,
  degree-name: none,
  submission-month-year: none,
  submission-year: none,
  report-type: none,
  supervisor-name: none,
  course-code: none,
  project-phase: none,
  term-info: none,
  abstract: none,
  acknowledgements: none,
  list-of-symbols: none,
  list-of-appendices: none,
  list-of-terminologies: none,
  doc,
) = {
  // Typography
  set text(font: "Arial", size: 12pt, lang: "en")
  show figure: set par(
    leading: 0.35em,
    first-line-indent: 0pt,
    spacing: 0.65em,
  )

  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    it
  }

  show figure.where(kind: image): it => {
    set figure.caption(position: bottom)
    it
  }

  // Headings
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    if it.numbering != none {
      pagebreak(weak: true)
      align(center)[
        #text(size: 14pt, weight: "bold", upper([Chapter ] + counter(heading).display() + [: ] + it.body))
      ]
    } else {
      align(center)[
        #text(size: 14pt, weight: "bold", upper(it.body))
      ]
    }
  }
  show heading.where(level: 2): it => {
    v(12pt)
    text(size: 12pt, weight: "bold", it)
    v(6pt)
  }
  show heading.where(level: 3): it => {
    v(12pt)
    text(size: 12pt, weight: "bold", it)
    v(6pt)
  }
  show heading.where(level: 4): it => {
    v(12pt)
    text(size: 12pt, weight: "bold", it)
    v(6pt)
  }


  // Cover Page
  if title != none {
    set page(margin: (left: 25.4mm, right: 25.4mm, top: 25.4mm, bottom: 25.4mm), numbering: none)
    align(center)[
      #v(-0.5cm)
      #image("logo.png", width: 65%)
      #v(1.5cm)
      #text(size: 14pt, weight: "bold", upper([Final Year Project ] + report-type + [ Report]))
      #v(2cm)
      #text(size: 14pt, weight: "bold", project-id)
      #v(0.5cm)
      #text(size: 14pt, weight: "bold", upper(title))
      #v(1fr)
      #text(size: 14pt, weight: "bold", student-id)
      #v(0.5cm)
      #text(size: 14pt, weight: "bold", upper(student-name))
      #v(1fr)
      #text(size: 14pt, weight: "bold", upper(programme))
      #v(1cm)
      #text(size: 14pt, weight: "bold", upper(submission-month-year))
      #v(1cm)
    ]
    pagebreak()
  }

  // Title Page
  if title != none {
    set page(margin: (left: 25.4mm, right: 25.4mm, top: 25.4mm, bottom: 25.4mm), numbering: none)
    align(center)[
      #v(1cm)
      #text(size: 14pt, weight: "bold", project-id)
      #v(0.5cm)
      #text(size: 14pt, weight: "bold", upper(title))
      #v(1fr)
      #text(size: 12pt, weight: "bold", [BY])
      #v(1cm)
      #text(size: 12pt, weight: "bold", student-id + "    " + upper(student-name))
      #v(1fr)
      #text(size: 12pt, upper([Project ] + report-type + [ Report Submitted In Partial Fulfilment Of The]))
      #v(0.3cm)
      #text(size: 12pt, upper([Requirement For The Degree Of]))
      #v(0.5cm)
      #text(size: 12pt, weight: "bold", upper(degree-name))
      #v(1cm)
      #text(size: 12pt, [in the])
      #v(0.5cm)
      #text(size: 12pt, [Faculty of Computing and Informatics])
      #v(2cm)
      #text(size: 14pt, weight: "bold", [MULTIMEDIA UNIVERSITY])
      #v(0.3cm)
      #text(size: 14pt, weight: "bold", [MALAYSIA])
      #v(1.5cm)
      #text(size: 12pt, submission-month-year)
      #v(1cm)
    ]
    pagebreak()
  }

  // --- Start Preliminary pages with Roman Numerals ---
  set page(
    margin: (left: 38mm, right: 28mm, top: 28mm, bottom: 28mm),
    numbering: "i",
    header: [
      #set text(size: 10pt)
      #box(width: 110%, align(right)[
        #context counter(page).display("i")
      ])
      Project ID: #project-id
      #h(1fr)
      #v(-0.5em)
      #line(length: 100%, stroke: 1.5pt + mmu-blue)
    ],
    footer: [
      #set text(size: 8pt)
      #line(length: 100%, stroke: 1.5pt + mmu-blue)
      #grid(
        columns: (1fr, auto, 1fr),
        align(left)[Prepared by: #student-name], align(center)[#course-code], align(right)[#term-info],
      )
      #v(15mm)
    ],
  )

  // Copyright Page
  [
    #heading(level: 1, numbering: none, outlined: true)[Copyright]
    #v(3cm)
    #align(center)[
      #text(size: 12pt)[(c) #submission-year Universiti Telekom Sdn. Bhd. ALL RIGHTS RESERVED.]
    ]
    #v(2cm)
    Copyright of this report belongs to Universiti Telekom Sdn. Bhd. as qualified by Regulation 7.2 (c) of the Multimedia University Intellectual Property and Commercialisation Policy. No part of this publication may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Universiti Telekom Sdn. Bhd. Due acknowledgement shall always be made of the use of any material contained in, or derived from, this report.
    #pagebreak()
  ]

  // Declaration Page
  [
    #heading(level: 1, numbering: none, outlined: true)[Declaration]
    #v(2cm)
    I hereby declare that the work has been done by myself and no portion of the work contained in this report has been submitted in support of any application for any other degree or qualification of this or any other university or institution of learning.
    #v(4cm)
    #line(length: 8cm, stroke: 0.4pt)
    Name of candidate: #upper(student-name) \
    Faculty of Computing & Informatics \
    Multimedia University \
    Date: #box(width: 4cm, stroke: (bottom: 1pt))
    #pagebreak()
  ]

  // Acknowledgements
  if acknowledgements != none [
    #heading(level: 1, numbering: none, outlined: true)[Acknowledgements]
    #v(1cm)
    #acknowledgements
    #pagebreak()
  ]

  // Abstract
  if abstract != none [
    #heading(level: 1, numbering: none, outlined: true)[Abstract]
    #v(1cm)
    #abstract
    #pagebreak()
  ]

  // TOC
  [
    #heading(level: 1, numbering: none, outlined: false)[Table of Contents]
    #v(1cm)
    #outline(title: none, indent: auto)
    #pagebreak()

    #heading(level: 1, numbering: none, outlined: true)[List of Tables]
    #v(1cm)
    #outline(title: none, target: figure.where(kind: "quarto-float-tbl").or(figure.where(kind: table)))
    #pagebreak()

    #heading(level: 1, numbering: none, outlined: true)[List of Figures]
    #v(1cm)
    #outline(title: none, target: figure.where(kind: "quarto-float-fig").or(figure.where(kind: image)))
    #pagebreak()

    #if list-of-symbols != none [
      #heading(level: 1, numbering: none, outlined: true)[List of Abbreviations / Symbols]
      #v(1cm)
      #list-of-symbols
      #pagebreak()
    ]

    #if list-of-appendices != none [
      #heading(level: 1, numbering: none, outlined: true)[List of Appendices]
      #v(1cm)
      #list-of-appendices
      #pagebreak()
    ]
    #if list-of-terminologies != none [
      #heading(level: 1, numbering: none, outlined: true)[List of Terminologies]
      #v(1cm)
      #list-of-terminologies
      #pagebreak()
    ]
  ]
  set par(justify: true, leading: 0.5em, first-line-indent: 12.7mm, spacing: 1.0em)

  // --- Main Matter Arabic numbering ---
  counter(page).update(1)
  set page(
    margin: (left: 38mm, right: 28mm, top: 28mm, bottom: 28mm),
    numbering: "1",
    header: [
      #set text(size: 10pt)
      #box(width: 110%, align(right)[
        #context counter(page).display("1")
      ])
      #set text(size: 8pt)
      Project ID: #project-id
      #h(1fr)
      #v(-0.5em)
      #line(length: 100%, stroke: 1.5pt + mmu-blue)
    ],
    footer: [
      #set text(size: 8pt)
      #line(length: 100%, stroke: 1.5pt + mmu-blue)
      #grid(
        columns: (1fr, auto, 1fr),
        align(left)[Prepared by: #student-name], align(center)[#course-code], align(right)[#term-info],
      )
      #v(15mm)
    ],
  )

  doc
}
