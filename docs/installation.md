# Installation

This guide explains how to install this Neovim configuration from scratch, verify it, and fix common setup issues. It is written for both first-time Neovim users and experienced users who want a reproducible setup.

## Prerequisites

### Required tools

| Tool | Minimum | Why it is needed |
| --- | --- | --- |
| Neovim | `0.11+` | Core editor version this config is built for |
| `git` | Any recent version | Clone the repository and manage updates |
| `make` | Any recent version | Builds native plugin components (when available) |
| `unzip` | Any recent version | Used by plugin/tooling workflows |
| `rg` (ripgrep) | Any recent version | Fast text search integration |

Check installed versions:

```bash
nvim --version
git --version
make --version
unzip -v
rg --version
```

### Competitive programming tools (recommended)

| Tool | Why it is needed |
| --- | --- |
| `g++` | Compile C/C++ solutions (`<F5>`, `<F9>`, `:CPRun`) |
| `clangd` | C/C++ language intelligence (LSP) |
| `clang-format` | C/C++ formatting with 4-space style |

Optional for Java quick run (`:R` on Java files):

| Tool | Why it is needed |
| --- | --- |
| `javac` and `java` | Compile and run Java files directly from Neovim |

## Step-by-Step Setup

### 1. Install dependencies

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y neovim git make unzip ripgrep g++ clangd clang-format
```

Fedora:

```bash
sudo dnf install -y neovim git make unzip ripgrep gcc-c++ clang-tools-extra
```

Arch Linux:

```bash
sudo pacman -S --needed neovim git make unzip ripgrep gcc clang clang-tools-extra
```

macOS (Homebrew):

```bash
brew install neovim git make unzip ripgrep gcc llvm
```

### 2. Back up any existing Neovim config (recommended)

If you already use Neovim, back up your current config so you can restore it later:

```bash
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d-%H%M%S)
```

You can also isolate this config without replacing your default setup:

```bash
git clone https://github.com/rahulsamant37/neovim-setup ~/.config/nvim-rahul
NVIM_APPNAME=nvim-rahul nvim
```

Why this is useful: you can test this config safely before making it your default.

### 3. Clone this configuration

```bash
git clone https://github.com/rahulsamant37/neovim-setup ~/.config/nvim
```

### 4. Launch Neovim once

```bash
nvim
```

On first launch, `lazy.nvim` bootstraps itself and installs configured plugins.

### 5. Run health checks

Inside Neovim:

```vim
:checkhealth
:Lazy
```

Why this matters:

- `:checkhealth` catches missing executables and environment problems.
- `:Lazy` confirms plugin install/update state.

### 6. Validate CP workflow (quick smoke test)

```bash
mkdir -p ~/cp-smoke
cd ~/cp-smoke
nvim main.cpp
```

Inside Neovim:

1. Enter insert mode, type `cpbasic`, then expand snippet.
2. Press `<leader>t` to create/open `input1.txt` and `output1.txt`.
3. Press `<F5>` to compile and run.
4. Press `<leader>cd` to compare `output.txt` with expected output.

If this works, the main CP loop is ready.

## Updating the Config

Update your config and plugins:

```bash
cd ~/.config/nvim
git pull
nvim +"Lazy sync" +qa
```

## Troubleshooting

### Neovim version is too old

Symptom:

- Health check reports version warnings.

Fix:

- Install Neovim `0.11+` from official releases or a newer package source.

### Plugin install failed on first launch

Symptom:

- Missing plugins or startup errors.

Fix:

```vim
:Lazy sync
```

Then restart Neovim.

### C/C++ compile or run fails

Symptom:

- `<F5>`/`:CPRun` fails or cannot find compiler.

Fix:

```bash
g++ --version
which g++
```

Ensure `g++` is installed and available in `PATH`.

### LSP for C/C++ is missing

Symptom:

- No diagnostics/completion for `.cpp`.

Fix:

```bash
clangd --version
which clangd
```

Install `clangd` and restart Neovim.

### Formatting does not work as expected

Symptom:

- `<leader>f` does not format, or indent is unexpected.

Fix:

- Install `clang-format` for C/C++ and `stylua` for Lua.
- For C/C++, this config intentionally avoids LSP fallback formatting and prefers `clang-format`.

### Telescope native sorter did not build

Symptom:

- Fuzzy finder still works, but may feel slower.

Why:

- `telescope-fzf-native.nvim` builds only when `make` is available.

Fix:

- Install `make` and run `:Lazy sync` again.
