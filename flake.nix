{
  description = "A Nix-based development environment for the MCP testing sensei.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      
      # Create a Python environment with runtime dependencies
      pythonEnv = pkgs.python312.withPackages (ps: with ps; [
        mcp
        pytest
      ]);
      
      # Create a Python environment with build/distribution tools
      pythonBuildEnv = pkgs.python312.withPackages (ps: with ps; [
        mcp
        pytest
        build
        twine
        setuptools
        wheel
      ]);

    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            pythonBuildEnv
            pkgs.poetry
            pkgs.ruff
            pkgs.mypy
            pkgs.nodejs_22
            pkgs.nodePackages.npm
            pkgs.docker
            pkgs.docker-compose
            pkgs.git
            pkgs.gh
            pkgs.jq
          ];
          
          shellHook = ''
            echo "MCP Testing Sensei Development Environment"
            echo "Python version: $(python --version)"
            echo "Node version: $(node --version)"
            echo "npm version: $(npm --version)"
            echo ""
            echo "Available commands:"
            echo "  python mcp_server.py      - Run the MCP stdio server"
            echo "  python test_mcp_integration.py - Run integration tests"
            echo "  pytest                    - Run unit tests"
            echo "  make dist                 - Build all distributions"
            echo "  make publish-test         - Publish to test PyPI"
            echo "  make docker-build         - Build Docker image"
            echo ""
          '';
        };
        
        # Minimal shell for just running the server
        runtime = pkgs.mkShell {
          buildInputs = [ pythonEnv ];
        };
      };

      # Packages
      packages.${system} = {
        # Main server package
        default = pkgs.writeShellScriptBin "mcp-testing-sensei" ''
          # Run from the directory containing this script
          DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"
          if [ -f "$DIR/../share/mcp-testing-sensei/mcp_server.py" ]; then
            # Installed via nix
            cd "$DIR/../share/mcp-testing-sensei"
          elif [ -f "./mcp_server.py" ]; then
            # Running from source
            true
          else
            echo "Error: Cannot find mcp_server.py"
            exit 1
          fi
          exec ${pythonEnv}/bin/python mcp_server.py "$@"
        '';
        
        # Docker image
        docker = pkgs.dockerTools.buildImage {
          name = "mcp-testing-sensei";
          tag = "latest";
          contents = [ pythonEnv ];
          config = {
            Cmd = [ "${pythonEnv}/bin/python" "/app/mcp_server.py" ];
            WorkingDir = "/app";
          };
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ ];
            pathsToLink = [ ];
            extraPrefix = "/app";
            postBuild = ''
              cp ${./mcp_server.py} $out/app/mcp_server.py
              cp ${./linter.py} $out/app/linter.py
            '';
          };
        };
      };
      
      # Utility apps for distribution
      apps.${system} = {
        # Build Python distribution
        build-pypi = {
          type = "app";
          program = "${pkgs.writeShellScript "build-pypi" ''
            echo "Building Python distribution..."
            ${pythonBuildEnv}/bin/python -m build
          ''}";
        };
        
        # Build npm package
        build-npm = {
          type = "app";
          program = "${pkgs.writeShellScript "build-npm" ''
            echo "Building npm package..."
            ${pkgs.nodejs_22}/bin/npm pack
          ''}";
        };
        
        # Run all tests
        test-all = {
          type = "app";
          program = "${pkgs.writeShellScript "test-all" ''
            echo "Running all tests..."
            ${pythonEnv}/bin/pytest
            ${pythonEnv}/bin/python test_mcp_integration.py
          ''}";
        };
        
        # Release helper
        release = {
          type = "app";
          program = "${pkgs.writeShellScript "release" ''
            set -e
            VERSION=''${1:-$(grep version pyproject.toml | head -1 | cut -d'"' -f2)}
            echo "Preparing release v$VERSION..."
            
            # Update versions
            ${pkgs.gnused}/bin/sed -i "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" package.json
            ${pkgs.gnused}/bin/sed -i "s/version = \".*\"/version = \"$VERSION\"/" setup.py
            
            echo "Version updated to $VERSION"
            echo "Run 'git add -A && git commit -m \"Release v$VERSION\"' to commit"
          ''}";
        };
      };
    };
}
