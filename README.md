# a-long-view

_Version 0.1.0_

Open materials for the paper "Immigration and Labor Market Integration in Germany: A Long View" by
[Maximilian Sprengholz](mailto:maximilian.sprengholz@hu-berlin.de), [Claudia Diehl](mailto:claudia.diehl@uni-konstanz.de), [Johannes Giesecke](johannes.giesecke@hu-berlin.de) and [Michaela Kreyenfeld](Kreyenfeld@hertie-school.org).


## Project organization

```
.
├── .gitignore
├── CITATION.md
├── LICENSE.md
├── README.md
├── requirements.txt
├── bin                <- Compiled and external code, ignored by git (PG)
│   └── external       <- Any external source code, ignored by git (RO)
├── config             <- Configuration files (HW)
├── data               <- All project data, ignored by git
│   ├── processed      <- The final, canonical data sets for modeling. (PG)
│   ├── raw            <- The original, immutable data dump. (RO)
│   └── temp           <- Intermediate data that has been transformed. (PG)
├── docs               <- Documentation notebook for users (HW)
│   ├── manuscript     <- Manuscript source, e.g., LaTeX, Markdown, etc. (HW)
│   └── reports        <- Other project reports and notebooks (e.g. Jupyter, .Rmd) (HW)
├── results
│   ├── figures        <- Figures for the manuscript or reports (PG)
│   └── output         <- Other output for the manuscript or reports (PG)
└── src                <- Source code for this project (HW)

```
Repository organization implemented with [cookiecutter](https://github.com/cookiecutter/cookiecutter) using the [good-enough-project template](good-enough-project).

## Data
The main data used in this project are the Scientific Use Files (SUFs) 1976-2015 of the German Microsensus
(DOI: [10.21242/12211.1976.00.00.3.1.0](https://doi.org/10.21242/12211.1976.00.00.3.1.0) to [10.21242/12211.2015.00.00.3.1.0](https://doi.org/10.21242/12211.2015.00.00.3.1.0)). These files are not openly accessible and have to be [requested](https://www.forschungsdatenzentrum.de/en/request).

All other data used is part of this repository.

## Software

This project was implemented in [Stata 15.1](https://www.stata.com/), but should run in older versions, too. You find the master file under `src/mz_o_00_master.do`.

The following user-written programs need to be installed in order to run the full code (see installation instructions in the linked documentations):

- [grstyle](http://repec.sowi.unibe.ch/stata/grstyle/index.html). Jann, B. (2018) ‘Customizing Stata Graphs Made Easy (Part 1)’, The Stata Journal: Promoting communications on statistics and Stata, 18, 491–502.
- [tabout v3](http://tabout.net.au/). Watson, I. (2019).

Further external code used:

- [isei_mz_96-04.do](https://www.gesis.org/missy/files/documents/MZ/isei/isei_mz_96-04.do). Kogan, I. and Schimpl-Neimanns, B. (2006) Recodierung von ISEI auf Basis von ISCO-88 (COM). German Microdata Lab (GML), Mannheim
- [Programme zur Umsetzung der Bildungsklassifikation ISCED-1997](https://www.gesis.org/missy/materials/MZ/tools/isced), German Microdata Lab (GML), Mannheim. Used for years 1976-2013, source files under `bin/external`.

The online appendix/documentation was created in [Atom](https://github.com/atom/atom) with [Markdown Preview Enhanced](https://github.com/shd101wyy/markdown-preview-enhanced), [Pandoc](https://github.com/jgm/pandoc) and [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref).


## License

This project is licensed under the terms of the [MIT License](/LICENSE.md)

## Citation

Please [cite this project as described here](/CITATION.md).
