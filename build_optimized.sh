#!/bin/bash
set -e

echo "Building optimized executable..."

# Clean previous builds
rm -rf build dist

# Set Python optimization flags
export PYTHONOPTIMIZE=2

# Build with the optimized spec
pyinstaller mcp_testing_sensei_optimized.spec \
    --clean \
    --onefile \
    --log-level WARN

# Get the executable name based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    EXEC_NAME="mcp-testing-sensei"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    EXEC_NAME="mcp-testing-sensei"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    EXEC_NAME="mcp-testing-sensei.exe"
fi

# Show size
if [ -f "dist/$EXEC_NAME" ]; then
    echo "Build complete!"
    ls -lh "dist/$EXEC_NAME"

    # Additional compression with UPX if available and not on macOS
    if command -v upx &> /dev/null && [[ "$OSTYPE" != "darwin"* ]]; then
        echo "Applying additional UPX compression..."
        upx --best --lzma "dist/$EXEC_NAME" || true
        echo "After UPX:"
        ls -lh "dist/$EXEC_NAME"
    fi
fi
