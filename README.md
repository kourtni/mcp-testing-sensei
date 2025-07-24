# MCP Unit Test Sensei

This project implements an MCP (Model Context Protocol) server designed to enforce and guide agentic coding tools (like Gemini CLI or Claude Code) in adhering to general unit testing standards.

## Core Principles Enforced

This linter aims to promote the following unit testing principles:

*   **Tests should be written before implementation.** (BDD/TDD for the win)
*   **Tests should document the behavior of the system under test.**
*   **Tests should be small, clearly written, and have a single concern.**
*   **Tests should be deterministic and isolated from the side effects of their environment and other tests.**
*   **Tests should be written in a declarative manner and never have branching logic.**

## Features

*   **Linting Endpoint (`/lint`)**: Analyzes provided code snippets for violations of the defined unit testing standards.
*   **Principles Endpoint (`/testing-principles`)**: Provides the core unit testing principles to guide LLMs in generating better tests.
*   **MCP Discovery (`/.well-known/model-context-protocol`)**: Allows MCP-compatible tools to discover the linter's capabilities.

## Getting Started

### Prerequisites

*   [Nix](https://nixos.org/download/) (for reproducible development environment)

### Development Environment Setup

To enter the development environment with all dependencies:

```bash
nix develop
```

### Building the Standalone Executable

To build the standalone executable using Nix, run the following command:

```bash
nix build
```

This will create a `result` symlink in your project root, pointing to the built executable.

### Running the Server

#### Using the Standalone Executable

After building, you can run the server directly from the `result` symlink:

```bash
./result/bin/mcp-unit-test-linter --port 8181
```

This will start the server, typically accessible at `http://localhost:8181`.

#### Running from Development Environment

Alternatively, if you are in the `nix develop` shell, you can start the FastAPI server:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

This will start the server, typically accessible at `http://localhost:8000`.

### Testing the Endpoints

#### Linting Code

```bash
curl -X POST -H "Content-Type: application/json" -d '{"code": "def test_example():\n    if True:\n        pass"}' http://localhost:8000/lint
```

#### Getting Testing Principles

```bash
curl http://localhost:8000/testing-principles
```

#### MCP Discovery

```bash
curl http://localhost:8000/.well-known/model-context-protocol
```

### Running Tests

To run the unit tests locally, first ensure you are in the Nix development environment:

```bash
nix develop
```

Then, execute `pytest`:

```bash
pytest
```

## Project Structure

```
.mcp.json
flake.lock
flake.nix
linter.py
main.py
pyproject.toml
server.log
.gemini/
    settings.json
```

## Contributing

Contributions are welcome! Please ensure your changes adhere to the established unit testing principles and project conventions.

```
