# Neovim Setup

Personal Neovim configuration built on kickstart.nvim, focused on a clean Lua setup and a fast C++ competitive programming workflow.

Repository: https://github.com/rahulsamant37/neovim-setup

## Introduction

This configuration is for users who want:

- A practical Neovim base with modern defaults
- A CP-focused C++ workflow (compile, run, test, compare)
- A modular structure that is easy to understand and extend

It is not a full Neovim distribution. It is a personal setup meant to be forked and adapted.

## Features

### Core editor

- Plugin manager: lazy.nvim
- LSP and tooling: nvim-lspconfig
- Completion: blink.cmp + LuaSnip
- Syntax parsing: nvim-treesitter
- Formatting: conform.nvim
- Search/navigation: telescope.nvim
- Git integration: gitsigns.nvim + vim-fugitive

### Competitive programming

- Fast compile and run for C/C++
- Compile-only checks
- Compile modes for fast/debug/submit workflows
- Test file management helpers
- Output comparison helpers
- Built-in stress testing command
- Multiple C++ snippet templates

## Installation

### 1. Install Neovim

This setup targets Neovim 0.11 or newer.

Check your version:

```bash
nvim --version
```

If your package manager gives an outdated version, install from Neovim releases:
https://github.com/neovim/neovim/releases

### 2. Install external dependencies

Required tools:

- git
- make
- unzip
- rg (ripgrep)

C++ workflow tools:

- g++ (C++23 recommended)
- clangd (recommended)
- clang-format (recommended for consistent formatting)

Install options by environment:

<details>
<summary>Ubuntu / Debian</summary>

```bash
sudo apt update
sudo apt install -y git make unzip ripgrep g++ clangd clang-format
```

</details>

<details>
<summary>Fedora</summary>

```bash
sudo dnf install -y git make unzip ripgrep gcc-c++ clang-tools-extra
```

</details>

<details>
<summary>Arch Linux</summary>

```bash
sudo pacman -S --needed git make unzip ripgrep gcc clang clang-tools-extra
```

</details>

<details>
<summary>macOS (Homebrew)</summary>

```bash
brew install git make unzip ripgrep gcc llvm
```

</details>

### 3. Clone this repository

```bash
git clone https://github.com/rahulsamant37/neovim-setup ~/.config/nvim
```

### 4. Start Neovim

```bash
nvim
```

On first launch, lazy.nvim bootstraps and installs configured plugins automatically.

### 5. Validate setup

Inside Neovim:

```vim
:checkhealth
```

## Quick Start

### General

1. Open Neovim.
2. Leader key is Space.
3. Use Space s f to find files.
4. Use Space s g to search text.

### Competitive programming

1. Open a .cpp file.
2. Expand a snippet such as cpbasic or cpfull.
3. Press F5 to compile and run.
4. Use Space t to create/open test files.
5. Use Space c d to compare output.txt and output1.txt.
6. Use Space c m to cycle compile mode (fast/debug/submit).
7. Use Space c s to run stress tests.

## Snippet Triggers (C++)

Available snippet triggers in lua/snippets/cpp.lua:

- cpbasic
- cpfull
- cpinter
- cpext
- cpa
- basiccpp

## Keybindings

### General

| Key | Action |
| --- | --- |
| Space s f | Find files (Telescope) |
| Space s g | Live grep (Telescope) |
| Space s h | Help tags |
| Space q | Open diagnostics list |
| Ctrl h / j / k / l | Move between splits |
| Esc Esc (terminal mode) | Exit terminal mode |

### Competitive programming (C/C++ buffers)

| Key | Action |
| --- | --- |
| F5 | Compile and run |
| F9 | Compile only |
| F6 | Run compiled binary with custom input |
| Space c r | Compile and run |
| Space c c | Compile check only |
| Space c i | Run with custom input |
| Space t | Create/open test files |
| Space c t | Create/open test files |
| Space c d | Compare output.txt with output1.txt |
| Space c n | Create new CP file from snippet template |
| Space c s | Run stress test (defaults: gen.cpp + brute.cpp) |
| Space c m | Cycle compile mode (fast/debug/submit) |
| Space c M | Choose compile mode from menu |

### Competitive programming commands

| Command | Action |
| --- | --- |
| :CPMode fast\|debug\|submit | Set compile mode |
| :CPCycleMode | Cycle compile mode |
| :CPStress [gen.cpp] [brute.cpp] [iters] | Run stress tests |

## Project Structure

```text
.
├── init.lua
├── lazy-lock.json
├── README.md
└── lua
    ├── custom
    │   ├── cp-config.lua
    │   └── plugins
    │       ├── cp-setup.lua
    │       └── init.lua
    ├── kickstart
    │   ├── health.lua
    │   └── plugins
    └── snippets
        └── cpp.lua
```

## Customization

- init.lua: global options, keymaps, and plugin bootstrap
- lua/custom/cp-config.lua: CP functions and keymaps
- lua/custom/plugins/init.lua: personal plugin list
- lua/custom/plugins/cp-setup.lua: C++ LSP/treesitter settings
- lua/snippets/cpp.lua: C++ templates/snippets

## Optional: Run in Parallel with Existing Neovim Config

If you already have another setup and want to try this config without replacing it:

```bash
git clone https://github.com/rahulsamant37/neovim-setup ~/.config/nvim-rahul
NVIM_APPNAME=nvim-rahul nvim
```

## Troubleshooting

- Run :Lazy sync if plugins are missing
- Run :checkhealth to diagnose dependency issues
- If C++ LSP is missing, verify clangd is installed and in PATH
- If C/C++ formatting does not work, verify clang-format is installed and in PATH
- If compile/run fails, verify g++ installation and PATH

## Notes

- Leader key is Space
- Theme is tokyonight-night
- Nerd Font icons are disabled by default
- C/C++ indentation is set to 4 spaces