#!/bin/bash
# Test version of install script using temp directory

set -e

INSTALL_DIR=$(mktemp -d)
echo "Testing installation in: $INSTALL_DIR"

# Simulate downloading files (copy from current dir)
cp mcp_server.py "$INSTALL_DIR/"
cp linter.py "$INSTALL_DIR/"
cp requirements.txt "$INSTALL_DIR/"

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
echo "Test directory: $INSTALL_DIR"
echo ""
echo "Testing the installation..."
# Test if the server starts
timeout 2 bash "$INSTALL_DIR/run.sh" 2>&1 | head -10 || true
echo "Server test completed (expected to timeout as it waits for input)"

echo ""
echo "Cleaning up..."
rm -rf "$INSTALL_DIR"
echo "Test completed!"