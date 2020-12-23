FROM kenose/pandoc-python:latest

LABEL maintainer="Maximilian Sprengholz <maximilian.sprengholz@hu-berlin.de>"

# create dir and copy files
RUN mkdir -p /repo_clone && mkdir -p /repo_clone/results && mkdir -p /repo_clone/docs
COPY results repo_clone/results
COPY appendix.md repo_clone/docs/
COPY dep repo_clone/docs/dep
WORKDIR repo_clone/docs/

# Versioning is done via git, but the date can be manually updated here
RUN export DATE=$(date '+%y-%m-%d') \
    && python dep/regexrep.py 'appendix.md' '(date:[\s])(.*)' '\1"' ${DATE} '"'

# Call Pandoc
RUN pandoc --filter pandoc-include --filter pandoc-crossref --citeproc \
    --bibliography=dep/appendix.bib --csl=dep/journal-of-family-research.csl \
    --number-sections --table-of-contents -c dep/empty.css -H dep/vue_extended_h.css \
    appendix.md -H dep/lightbox.js -s -o appendix.html
