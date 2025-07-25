# Release and Distribution Guide

This guide covers all the distribution methods and release processes for MCP Testing Sensei.

## Prerequisites

All distribution tools are available in the Nix development environment:

```bash
nix develop
```

This provides:
- Python with build, twine, setuptools
- Node.js 22 with npm
- Docker and docker-compose
- Git and GitHub CLI
- Release automation tools

## Quick Release

For a complete release to all platforms:

```bash
# Using Nix
nix develop
make release VERSION={version}
make publish-all

# Or using the release script
./scripts/release.sh {version}
```

## Distribution Methods

### 1. PyPI (Python Package Index)

#### Setup
1. Create a PyPI account at https://pypi.org
2. Generate an API token
3. Create `~/.pypirc` (see `.pypirc.example`)

#### Build and Publish
```bash
# Build
python -m build
# or
nix run .#build-pypi

# Test upload
python -m twine upload --repository testpypi dist/*

# Production upload
python -m twine upload dist/*
```

### 2. NPM (Node Package Manager)

#### Setup
1. Create an npm account at https://npmjs.com
2. Login: `npm login`
3. Or create `.npmrc` (see `.npmrc.example`)

#### Build and Publish
```bash
# Build
npm pack
# or
nix run .#build-npm

# Publish
npm publish --access public
```

### 3. Docker Hub

#### Setup
1. Create a Docker Hub account
2. Login: `docker login`

#### Build and Publish
```bash
# Build
docker build -t kourtni/mcp-testing-sensei:latest .
# or
nix build .#docker

# Tag with version
docker tag kourtni/mcp-testing-sensei:latest kourtni/mcp-testing-sensei:{version}

# Push
docker push kourtni/mcp-testing-sensei:latest
docker push kourtni/mcp-testing-sensei:{version}
```

### 4. Nix Flake

The Nix package is automatically available when you push to GitHub:

```bash
# Users can run directly
nix run github:kourtni/mcp-testing-sensei

# Or add to their flake
{
  inputs.mcp-test-sensei.url = "github:kourtni/mcp-testing-sensei";
}
```

### 5. GitHub Releases

Releases are created automatically by GitHub Actions when you push a tag:

```bash
git tag -a v{version} -m "Release v{version}"
git push origin v{version}
```

## Automated Release Process

### GitHub Actions Setup

1. Add the following secrets to your GitHub repository:
   - `PYPI_API_TOKEN` - PyPI API token
   - `NPM_TOKEN` - NPM automation token
   - `DOCKER_USERNAME` - Docker Hub username
   - `DOCKER_PASSWORD` - Docker Hub password

2. Push a version tag to trigger the release workflow:
   ```bash
   git tag -a v{version} -m "Release v{version}"
   git push origin v{version}
   ```

### Manual Release Process

1. **Update version numbers:**
   ```bash
   nix run .#release {version}
   ```

2. **Run tests:**
   ```bash
   nix run .#test-all
   ```

3. **Build all distributions:**
   ```bash
   make dist
   ```

4. **Commit and tag:**
   ```bash
   git add -A
   git commit -m "Release v{version}"
   git tag -a v{version} -m "Release v{version}"
   ```

5. **Publish to all platforms:**
   ```bash
   make publish-all
   ```

## Version Management

Version numbers should be updated in:
- `pyproject.toml` - Primary source of truth
- `setup.py` - For PyPI
- `package.json` - For NPM
- `flake.nix` - For Nix package (optional)

The release scripts handle this automatically.

## Testing Distributions

Before publishing:

1. **Test PyPI package:**
   ```bash
   pip install -i https://test.pypi.org/simple/ mcp-testing-sensei
   ```

2. **Test NPM package:**
   ```bash
   npm pack
   npm install -g kourtni-mcp-testing-sensei-{version}.tgz
   ```

3. **Test Docker image:**
   ```bash
   docker run -it kourtni/mcp-testing-sensei:test
   ```

4. **Test Nix package:**
   ```bash
   nix run .
   ```

## Troubleshooting

### PyPI Upload Fails
- Check your `.pypirc` configuration
- Ensure your API token has upload permissions
- Try test PyPI first

### NPM Publish Fails
- Run `npm login` to refresh authentication
- Check package name availability
- Ensure you have publish rights to the scope

### Docker Push Fails
- Run `docker login`
- Check image size (Docker Hub has limits)
- Verify repository exists

### Nix Build Fails
- Run `nix flake check`
- Ensure all files are git-tracked
- Check for syntax errors in `flake.nix`