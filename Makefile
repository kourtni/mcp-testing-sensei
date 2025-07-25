.PHONY: all clean dist test docker-build docker-push npm-build npm-publish pypi-build pypi-test pypi-publish

# Default target
all: dist

# Clean build artifacts
clean:
	rm -rf dist/ build/ *.egg-info/
	rm -rf node_modules/
	rm -f *.tgz
	rm -rf __pycache__/ .pytest_cache/
	find . -type d -name "__pycache__" -exec rm -rf {} +

# Run tests
test:
	pytest
	python test_mcp_integration.py

# Build all distributions
dist: sync-version pypi-build npm-build docker-build
	@echo "All distributions built successfully!"

# Python/PyPI distribution
pypi-build:
	python -m build

pypi-test:
	python -m twine upload --repository testpypi dist/*

pypi-publish:
	python -m twine upload dist/*

# Docker distribution
DOCKER_IMAGE ?= kourtni/mcp-testing-sensei
DOCKER_TAG ?= latest

docker-build:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker-push: docker-build
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

docker-test: docker-build
	@echo "Testing Docker image..."
	docker run --rm -i $(DOCKER_IMAGE):$(DOCKER_TAG) /bin/sh -c "exit 0" && echo "Docker image OK"

# NPM distribution
npm-build:
	npm pack

npm-publish:
	npm publish --access public

npm-test:
	npm pack --dry-run

# Nix distribution
nix-build:
	nix build

nix-test: nix-build
	./result/bin/mcp-testing-sensei --help 2>&1 | head -5 || true

# Release automation
VERSION ?= $(shell grep version pyproject.toml | head -1 | cut -d'"' -f2)

# Sync version across all files
sync-version:
	@echo "Syncing version $(VERSION) across all files..."
	@python scripts/sync-version.py

release: test sync-version
	@echo "Preparing release v$(VERSION)..."
	# Commit changes
	git add -A
	git commit -m "Release v$(VERSION)" || true
	git tag -a "v$(VERSION)" -m "Release v$(VERSION)"
	@echo "Release prepared. Run 'make publish-all' to publish."

publish-all: dist
	@echo "Publishing to all repositories..."
	$(MAKE) pypi-publish
	$(MAKE) npm-publish
	$(MAKE) docker-push
	git push origin main --tags
	@echo "All packages published!"

# Development helpers
dev-install:
	pip install -e .

format:
	ruff format .

lint:
	ruff check .
	mypy .
