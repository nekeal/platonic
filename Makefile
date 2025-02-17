.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -f coverage.xml
	rm -fr htmlcov/
	rm -fr .pytest_cache

test: ## run tests quickly with the default Python
	poetry run pytest

test-all: ## run tests on every Python version with tox
	poetry run tox

coverage: ## check code coverage quickly with the default Python
	poetry run pytest --cov=platonic_io
	poetry run coverage report -m
	poetry run coverage html
	$(BROWSER) htmlcov/index.html

quality-check: ## check quality of code
	poetry run black platonic_io tests
	poetry run isort platonic_io tests
	poetry run flake8 platonic_io tests
	poetry run mypy platonic_io tests

autoformatters: ## runs auto formatters
	poetry run black platonic_io tests
	poetry run isort platonic_io tests

docs: ## generate mkdocs HTML documentation, including API docs
	poetry run mkdocs build

servedocs: docs ## compile the docs watching for changes
	poetry run mkdocs serve

release: build ## package and upload a release
	poetry publish

build: clean ## builds source and wheel package
	poetry build
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	poetry install -E test
