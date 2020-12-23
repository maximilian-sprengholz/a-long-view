# (1) Copy from the results dir into docs to make files available to docker
# (2) Build document
# (3) Clean up files

.PHONY: copy build cleanup

copy:
	cp -R -f ../results .
	rm -f appendix.html # fix overwriting bug

build:
	docker build -t docs .
	docker rm -f docs || true # remove if already built and present
	docker create -t --name docs docs
	docker cp docs:/build/repo_clone/docs/appendix.html appendix.html
	docker stop docs
	docker rm -f docs

cleanup:
	rm -rf results

all: copy build cleanup
