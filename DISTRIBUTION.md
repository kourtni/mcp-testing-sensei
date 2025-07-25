# Distribution Guide for MCP Testing Sensei

## Installation Methods

### 1. PyPI (Recommended for Python users)
```bash
pip install mcp-testing-sensei
```

Claude Desktop config:
```json
{
  "mcpServers": {
    "testing-sensei": {
      "command": "mcp-testing-sensei"
    }
  }
}
```

### 2. NPX (Recommended for Node.js users)
```bash
npx @kourtni/mcp-testing-sensei
```

Claude Desktop config:
```json
{
  "mcpServers": {
    "testing-sensei": {
      "command": "npx",
      "args": ["@kourtni/mcp-testing-sensei"]
    }
  }
}
```

### 3. Docker
```bash
docker pull kourtni/mcp-testing-sensei
```

Claude Desktop config:
```json
{
  "mcpServers": {
    "testing-sensei": {
      "command": "docker",
      "args": ["run", "-i", "kourtni/mcp-testing-sensei"]
    }
  }
}
```

### 4. Nix
```bash
nix run github:kourtni/mcp-testing-sensei
```

Claude Desktop config:
```json
{
  "mcpServers": {
    "testing-sensei": {
      "command": "nix",
      "args": ["run", "github:kourtni/mcp-testing-sensei"]
    }
  }
}
```

### 5. Install Script
```bash
curl -sSL https://raw.githubusercontent.com/kourtni/mcp-testing-sensei/main/install.sh | bash
```

Then follow the configuration instructions printed by the script.

### 6. Manual Installation
1. Clone the repository
2. Install Python dependencies: `pip install mcp`
3. Configure Claude Desktop:
```json
{
  "mcpServers": {
    "testing-sensei": {
      "command": "python",
      "args": ["/path/to/mcp_server.py"]
    }
  }
}
```

## Publishing

### To PyPI:
```bash
python -m build
python -m twine upload dist/*
```

### To NPM:
```bash
npm publish --access public
```

### To Docker Hub:
```bash
docker build -t kourtni/mcp-testing-sensei .
docker push kourtni/mcp-testing-sensei
```

### To GitHub:
1. Push code to GitHub
2. Create a release
3. The Nix flake and install script will work automatically

## Best Practices

1. **Version Management**: Use semantic versioning
2. **Documentation**: Include clear installation and configuration instructions
3. **Testing**: Test each distribution method before release
4. **Updates**: Provide clear upgrade paths for each distribution method