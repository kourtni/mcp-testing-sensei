# -*- mode: python ; coding: utf-8 -*-
import sys
from PyInstaller.utils.hooks import collect_submodules

block_cipher = None

# Exclude unnecessary modules to reduce size
excluded_modules = [
    'tkinter',
    'matplotlib',
    'numpy',
    'pandas',
    'scipy',
    'PIL',
    'PyQt5',
    'PyQt6',
    'PySide2',
    'PySide6',
    'notebook',
    'IPython',
    'jupyter',
    'pytest',  # Not needed at runtime
    'setuptools',
    'pip',
    'wheel',
    'distutils',
    'test',
    'tests',
    'testing',
    'unittest',
    'pydoc',
    'doctest',
    'sphinx',
    'pygments.lexers.matlab',
    'pygments.lexers.web',
    'pygments.lexers.php',
    'pygments.lexers.ruby',
    'pygments.lexers.perl',
    'pygments.lexers.jvm',
    'pygments.lexers.sql',
    'pygments.lexers.fortran',
    'pygments.lexers.r',
]

# Only include necessary hidden imports
hidden_imports = [
    'mcp',
    'mcp.server',
    'mcp.server.models',
    'mcp.types',
    'typing_extensions',
    'pydantic',
    'anyio',
    'httpx',
    'certifi',
]

a = Analysis(
    ['mcp_server.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=hidden_imports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=excluded_modules,
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
    optimize=2,  # Enable Python optimization
)

# Remove unnecessary binaries
a.binaries = [b for b in a.binaries if not any(
    x in b[0].lower() for x in ['qt5', 'qt6', 'tk', 'tcl', 'matplotlib', 'numpy']
)]

# Remove test and documentation files
a.datas = [d for d in a.datas if not any(
    x in d[0].lower() for x in ['test', 'tests', 'doc', 'docs', 'example', 'examples', '.pyi']
)]

pyz = PYZ(
    a.pure,
    a.zipped_data,
    cipher=block_cipher,
)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='mcp-testing-sensei',
    debug=False,
    bootloader_ignore_signals=False,
    strip=True,  # Strip debug symbols on Linux/macOS
    upx=True,  # Use UPX compression
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
