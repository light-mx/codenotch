.PHONY: all help test lint clean install-all install-flutter install-electron install-maui

PYTHON ?= python3

all: help

help:
	@echo "macOS Migration Agents - Management Targets"
	@echo "==========================================="
	@echo "make test               - Run full automated test suite"
	@echo "make lint               - Validate syntax across all Python and JS tools"
	@echo "make install-all        - Install all agents, skills, and plugins into .agents/"
	@echo "make install-flutter    - Install mac-to-flutter agent and skill into .agents/"
	@echo "make install-electron   - Install mac-to-electron agent and skill into .agents/"
	@echo "make install-maui       - Install mac-to-maui agent and skill into .agents/"
	@echo "make clean              - Remove temporary caches and test artifacts"

test:
	$(PYTHON) -m unittest discover tests
	./tests/test_installer.sh

lint:
	$(PYTHON) -m py_compile tools/*.py install.py tests/*.py
	@echo "✓ All Python files compiled cleanly."

install-all:
	$(PYTHON) install.py --all --scope workspace

install-flutter:
	$(PYTHON) install.py --agent mac-to-flutter --skill swift-to-flutter --scope workspace

install-electron:
	$(PYTHON) install.py --agent mac-to-electron --skill swift-to-electron --scope workspace

install-maui:
	$(PYTHON) install.py --agent mac-to-maui --skill swift-to-dotnet-maui --scope workspace

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -name "*.pyc" -delete
	rm -rf .pytest_cache
	@echo "✓ Cleaned cache artifacts."
