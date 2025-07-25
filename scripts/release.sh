#!/usr/bin/env bash
# Comprehensive release script for MCP Testing Sensei

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get version from argument or pyproject.toml
VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    VERSION=$(grep version pyproject.toml | head -1 | cut -d'"' -f2)
fi

echo -e "${GREEN}MCP Testing Sensei Release Script${NC}"
echo -e "${GREEN}Version: $VERSION${NC}"
echo ""

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        return 1
    fi
}

# Pre-flight checks
echo "Running pre-flight checks..."
check_command git || exit 1
check_command python || exit 1
check_command npm || exit 1
check_command docker || exit 1

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update version in all files
echo "Updating version numbers..."
sed -i "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" package.json
sed -i "s/version = \".*\"/version = \"$VERSION\"/" setup.py
sed -i "s/version = \".*\"/version = \"$VERSION\"/" pyproject.toml || true

# Run tests
echo -e "\n${GREEN}Running tests...${NC}"
if command -v pytest &> /dev/null; then
    pytest || { echo -e "${RED}Tests failed!${NC}"; exit 1; }
fi

# Build distributions
echo -e "\n${GREEN}Building distributions...${NC}"

# Python
echo "Building Python package..."
python -m build || { echo -e "${RED}Python build failed!${NC}"; exit 1; }

# NPM
echo "Building NPM package..."
npm pack || { echo -e "${RED}NPM build failed!${NC}"; exit 1; }

# Docker
echo "Building Docker image..."
docker build -t mcp-testing-sensei:$VERSION . || { echo -e "${RED}Docker build failed!${NC}"; exit 1; }
docker tag mcp-testing-sensei:$VERSION mcp-testing-sensei:latest

# Create git tag
echo -e "\n${GREEN}Creating git tag...${NC}"
git add -A
git commit -m "Release v$VERSION" || true
git tag -a "v$VERSION" -m "Release v$VERSION" || true

echo -e "\n${GREEN}Release preparation complete!${NC}"
echo ""
echo "To publish this release:"
echo "  1. PyPI:   python -m twine upload dist/*"
echo "  2. NPM:    npm publish"
echo "  3. Docker: docker push kourtni/mcp-testing-sensei:$VERSION"
echo "  4. Git:    git push origin main --tags"
echo ""
echo "Or run: make publish-all"
