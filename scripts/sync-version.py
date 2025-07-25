#!/usr/bin/env python3
"""Sync version across all project files."""

import re
import sys
from pathlib import Path


def get_version_from_pyproject():
    """Extract version from pyproject.toml."""
    content = Path('pyproject.toml').read_text()
    match = re.search(r'^version = "(.+?)"', content, re.MULTILINE)
    if match:
        return match.group(1)
    raise ValueError('Version not found in pyproject.toml')


def update_file(filepath, pattern, replacement):
    """Update version in a file."""
    path = Path(filepath)
    if not path.exists():
        print(f'Skipping {filepath} (not found)')
        return

    content = path.read_text()
    new_content = re.sub(pattern, replacement, content)

    if content != new_content:
        path.write_text(new_content)
        print(f'Updated {filepath}')
    else:
        print(f'No change needed in {filepath}')


def main():
    """Sync version across all files."""
    try:
        version = get_version_from_pyproject()
        print(f'Syncing version: {version}')

        # Update package.json
        update_file('package.json', r'"version": "[^"]+?"', f'"version": "{version}"')

        # Update setup.py
        update_file('setup.py', r'version="[^"]+?"', f'version="{version}"')

        # Update flake.nix (if needed)
        update_file('flake.nix', r'version = "[^"]+?"', f'version = "{version}"')

        print(f'\n✓ Version {version} synced across all files')

    except Exception as e:
        print(f'Error: {e}', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
