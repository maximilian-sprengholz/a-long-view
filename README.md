# Open materials: 'From "guestworkers" to EU migrants: A gendered view on the labor market integration of different arrival cohorts in Germany'

Open materials for the paper 'From "guestworkers" to EU migrants: A gendered view on the labor market integration of different arrival cohorts in Germany' by
[Maximilian Sprengholz](mailto:maximilian.sprengholz@hu-berlin.de), [Claudia Diehl](mailto:claudia.diehl@uni-konstanz.de), [Johannes Giesecke](johannes.giesecke@hu-berlin.de) and [Michaela Kreyenfeld](Kreyenfeld@hertie-school.org).

__See [online appendix](http://pages.cms.hu-berlin.de/sprenmax/a-long-view/).__

## Project organization

```
.
├── .gitignore
├── LICENSE.md
├── README.md
├── bin                <- Compiled and external code
│   └── external       <- Any external source code
├── data               <- All project data
│   ├── processed      <- The final data set
│   ├── raw            <- The original, immutable data dump
│   └── temp           <- Intermediate data that has been transformed
├── docs               <- Documentation (.md -> .html, Makefile and Dockerfile)
│   └── dep            <- Dependencies for the .html generation
├── public             <- Published appendix (as page for repo)
├── results
│   ├── figures        <- Figures for the manuscript / appendix
│   └── output         <- Other output for the manuscript / appendix
└── src                <- Source code (.do)

```
Repository organization implemented with [cookiecutter](https://github.com/cookiecutter/cookiecutter) using an adapted version of the [good-enough-project template](good-enough-project).

## Data
The main data used in this project are the Scientific Use Files (SUFs) 1976-2015 of the German Microsensus
(DOI: [10.21242/12211.1976.00.00.3.1.0](https://doi.org/10.21242/12211.1976.00.00.3.1.0) to [10.21242/12211.2015.00.00.3.1.0](https://doi.org/10.21242/12211.2015.00.00.3.1.0)). These files are not openly accessible and have to be [requested](https://www.forschungsdatenzentrum.de/en/request).

All other data used is part of this repository.

## Software

This project was implemented in [Stata 15.1](https://www.stata.com/), but should run in older versions, too. You find the master file under `src/mz_o_00_master.do`.

The following user-written programs need to be installed in order to run the full code (see installation instructions in the linked documentations):

- [grstyle](http://repec.sowi.unibe.ch/stata/grstyle/index.html). Jann, B. (2018) ‘Customizing Stata Graphs Made Easy (Part 1)’, The Stata Journal: Promoting communications on statistics and Stata, 18, 491–502.
- [tabout v3](http://tabout.net.au/). Watson, I. (2019).

Further external code used (part of the do-files, no installation necessary):

- [isei_mz_96-04.do](https://www.gesis.org/missy/files/documents/MZ/isei/isei_mz_96-04.do). Kogan, I. and Schimpl-Neimanns, B. (2006) Recodierung von ISEI auf Basis von ISCO-88 (COM). German Microdata Lab (GML), Mannheim
- [Programme zur Umsetzung der Bildungsklassifikation ISCED-1997](https://www.gesis.org/missy/materials/MZ/tools/isced), German Microdata Lab (GML), Mannheim. Used for years 1976-2013, source files under `bin/external`.

## Documentation

The [online appendix](http://pages.cms.hu-berlin.de/sprenmax/a-long-view/) presents the results of our main as well as supplementary estimations. The file `docs/appendix.html` represents a copy of this page. In case you want to re-generate `docs/appendix.html` from `docs/appendix.md`, please use the provided `Makefile`. To run it, you need to have [Docker](https://www.docker.com/) installed (and Windows users also [Make](https://www.gnu.org/software/make/)):

```sh
cd path/to/a-long-view/docs
make all
```

The Docker image that is pulled in the process already contains all the necessary depencies. Alternatively, you can also do it manually given [Pandoc](https://github.com/jgm/pandoc), [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref), and [pandoc-include](https://pypi.org/project/pandoc-include/) (which requires Python) are installed:

```sh
cd path/to/a-long-view/docs

# Call Pandoc
pandoc --filter pandoc-include --filter pandoc-crossref --citeproc \
    --bibliography=dep/appendix.bib --csl=dep/journal-of-family-research.csl \
    --number-sections --table-of-contents -c dep/empty.css -H dep/vue_extended_h.css \
    appendix.md -H dep/lightbox.js -s -o appendix.html
```

Note that the version is not updated in either of these ways, as it is determined by git via a pipeline job and not available locally. The date is set to the current date when using the `Makefile`.

## License

This project is licensed under the terms of the [MIT License](/LICENSE.md)

## Citation

Please cite this software as:

Sprengholz, M., Diehl, C., Giesecke, J., Kreyenfeld, M. (2020) 'Open materials: From "guestworkers" to EU migrants: A gendered view on the labor market integration of different arrival cohorts in Germany', [https://scm.cms.hu-berlin.de/sprenmax/a-long-view](https://scm.cms.hu-berlin.de/sprenmax/a-long-view).
