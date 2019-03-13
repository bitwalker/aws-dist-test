.PHONY: help

ENGINE_VERSION ?= `grep 'version' apps/engine/mix.exs | sed -e 's/ //g' -e 's/version://' -e 's/[",]//g'`
WEB_VERSION ?= `grep 'version' apps/engine/mix.exs | sed -e 's/ //g' -e 's/version://' -e 's/[",]//g'`
IMAGE_NAME ?= distillery_example
PWD ?= `pwd`

help:
	@echo "$(IMAGE_NAME) (engine:$(ENGINE_VERSION), web:$(WEB_VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Initialize the project from a clean state
	mix local.rebar --force
	mix local.hex --force
	mix deps.get

compile: ## Build the application
	mix compile && cd apps/web && mix phx.digest

clean: ## Clean up generated artifacts
	mix clean

rebuild: clean compile ## Rebuild the application

image: ## Mimic CodeBuild build
	docker run --rm -e BUILD_DIR=/opt/app -v $(PWD):/opt/app -it centos:7 /opt/app/bin/build all

release: refresh-deps release-engine release-web ## Build a release of the application with MIX_ENV=prod
	@mkdir -p target/{engine,web}
	@cp _build/prod/rel/engine/releases/$(ENGINE_VERSION)/engine.tar.gz engine.tar.gz
	@cp _build/prod/rel/web/releases/$(WEB_VERSION)/web.tar.gz web.tar.gz

release-engine:
	MIX_ENV=prod mix release --name=engine --verbose

release-web:
	MIX_ENV=prod mix compile
	pushd apps/web && MIX_ENV=prod mix phx.digest && popd
	MIX_ENV=prod mix release --name=web --verbose

refresh-deps:
	MIX_ENV=prod mix deps.get
