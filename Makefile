.DEFAULT_GOAL := help

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: help
help:		## Print this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: clean
clean:	## Clean tests cache
	rm -Rf $(ROOT_DIR)/.tests

.PHONY: fmt
fmt:		## Format code
	stylua lua

.PHONY: lint
lint:		## Lint code
	selene lua

.PHONY: test
test:		## Run tests
	./minit.lua
