#!/bin/bash
# Install script for MCP Testing Sensei

set -e

INSTALL_DIR="$HOME/.local/mcp/testing-sensei"
REPO_URL="https://github.com/kourtni/mcp-testing-sensei"

echo "Installing MCP Testing Sensei..."

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Download files
curl -sL "$REPO_URL/raw/main/mcp_server.py" -o "$INSTALL_DIR/mcp_server.py"
curl -sL "$REPO_URL/raw/main/linter.py" -o "$INSTALL_DIR/linter.py"
curl -sL "$REPO_URL/raw/main/requirements.txt" -o "$INSTALL_DIR/requirements.txt"

# Create virtual environment and install dependencies
cd "$INSTALL_DIR"
python -m venv venv
./venv/bin/pip install -r requirements.txt

# Create wrapper script
cat > "$INSTALL_DIR/run.sh" << 'EOF'
#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec "$DIR/venv/bin/python" "$DIR/mcp_server.py" "$@"
EOF
chmod +x "$INSTALL_DIR/run.sh"

echo "Installation complete!"
echo ""
echo "Add this to your Claude Desktop config:"
echo '  "testing-sensei": {'
echo '    "command": "'"$INSTALL_DIR/run.sh"'"'
echo '  }'
