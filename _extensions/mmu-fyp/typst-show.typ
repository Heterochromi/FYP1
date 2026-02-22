#show: doc => article(
$if(title)$
  title: [$title$],
$endif$
$if(project-id)$
  project-id: "$project-id$",
$endif$
$if(student-id)$
  student-id: "$student-id$",
$endif$
$if(student-name)$
  student-name: "$student-name$",
$endif$
$if(programme)$
  programme: "$programme$",
$endif$
$if(degree-name)$
  degree-name: "$degree-name$",
$endif$
$if(submission-month-year)$
  submission-month-year: "$submission-month-year$",
$endif$
$if(submission-year)$
  submission-year: "$submission-year$",
$endif$
$if(report-type)$
  report-type: "$report-type$",
$endif$
$if(supervisor-name)$
  supervisor-name: "$supervisor-name$",
$endif$
$if(course-code)$
  course-code: "$course-code$",
$endif$
$if(project-phase)$
  project-phase: "$project-phase$",
$endif$
$if(term-info)$
  term-info: "$term-info$",
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$
$if(acknowledgements)$
  acknowledgements: [$acknowledgements$],
$endif$
$if(list-of-symbols)$
  list-of-symbols: [$list-of-symbols$],
$endif$
$if(list-of-appendices)$
  list-of-appendices: [$list-of-appendices$],
$endif$
  doc,
)
