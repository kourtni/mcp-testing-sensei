{
  description = "A Nix-based development environment for the MCP unit test linter.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      pythonPackages = pkgs.python3.withPackages (ps: [
        ps.fastapi
        ps.uvicorn
        ps.pytest
        ps.pydantic
        ps.pyinstaller
      ]);

      mcpLinterExecutable = pkgs.stdenv.mkDerivation {
        pname = "mcp-unit-test-linter-executable";
        version = "0.1.0";
        src = pkgs.lib.cleanSource ./.;
        buildInputs = [ pythonPackages ];
        buildPhase = ''
          ${pythonPackages}/bin/pyinstaller --onefile --hidden-import linter main.py
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp dist/main $out/bin/mcp-unit-test-linter
        '';
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pythonPackages
          pkgs.pre-commit
          pkgs.ruff
          pkgs.mypy
          pkgs.poetry
        ];
      };

      packages.${system}.mcp-unit-test-linter = mcpLinterExecutable;
      defaultPackage.${system} = self.packages.${system}.mcp-unit-test-linter;
    };
}
