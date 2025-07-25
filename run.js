#!/usr/bin/env node
const { spawn, execSync } = require('child_process');
const path = require('path');

// Check if Python is available
try {
  execSync('python --version', { stdio: 'ignore' });
} catch (e) {
  try {
    execSync('python3 --version', { stdio: 'ignore' });
  } catch (e) {
    console.error('Error: Python is not installed. Please install Python 3.9 or higher.');
    console.error('Visit https://www.python.org/downloads/ for installation instructions.');
    process.exit(1);
  }
}

// Check if MCP is installed
try {
  execSync('python -c "import mcp"', { stdio: 'ignore' });
} catch (e) {
  try {
    execSync('python3 -c "import mcp"', { stdio: 'ignore' });
  } catch (e) {
    console.error('Error: MCP Python package is not installed.');
    console.error('Please install it with: pip install mcp');
    console.error('Or: pip3 install mcp');
    process.exit(1);
  }
}

const serverPath = path.join(__dirname, 'mcp_server.py');
const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';

const python = spawn(pythonCmd, [serverPath], {
  stdio: 'inherit'
});

python.on('error', (err) => {
  console.error('Failed to start MCP server:', err);
  process.exit(1);
});

python.on('close', (code) => {
  process.exit(code);
});