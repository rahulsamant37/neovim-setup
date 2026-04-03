# Neovim Lua Configuration

Personal Neovim setup based on Kickstart, with competitive programming optimizations, and a clean Lua-first plugin layout.

## 🏆 Competitive Programming Setup

This configuration includes a complete CP workflow with:
- **Fast compile & run** (F5 key)
- **Multiple C++ templates** (cpbasic, cpfull, cpinter, etc.)
- **Automatic test file management** (input.txt, output.txt)
- **clangd LSP** for intelligent C++ completion
- **Debug macros** for quick debugging
- **Diff comparison** for output verification

**Quick Start for CP:**
1. Create a file: `nvim solution.cpp`
2. Type `cpbasic` and press Tab
3. Press `<F5>` to compile and run

📖 **See [CP_SETUP_GUIDE.md](CP_SETUP_GUIDE.md) for complete documentation**  
📋 **See [CP_QUICK_REFERENCE.md](CP_QUICK_REFERENCE.md) for quick reference**

## Highlights

- Plugin manager: `lazy.nvim`
- LSP + tool management: `nvim-lspconfig` (with clangd for C++)
- Completion: `blink.cmp` + `LuaSnip`
- Fuzzy finding: `telescope.nvim` (+ `telescope-fzf-native.nvim` when `make` is available)
- Syntax: `nvim-treesitter`
- Formatting: `conform.nvim` (Lua via `stylua`)
- Git: `gitsigns.nvim` + `vim-fugitive`
- UI: `tokyonight.nvim`, `which-key.nvim`, `mini.nvim`, `todo-comments.nvim`
- Jupyter workflow: `jupytext.nvim` + `molten-nvim`
- **CP optimizations**: Fast compile/run, templates, test management

## Custom Additions

This config enables custom plugins from `lua/custom/plugins/`:

- `vim-fugitive`
- `goerz/jupytext.nvim`
- `benlubas/molten-nvim`
- `gitsigns.nvim` tweak to skip attaching on `.ipynb` buffers

## Requirements

Minimum:

- Neovim `>= 0.11`
- `git`
- `make`
- `unzip`
- `rg` (ripgrep)

For C++ Competitive Programming:

- `g++` with C++23 support (or C++20)
- `clangd` (for LSP features)

For Jupyter integration (`molten-nvim`):

- Python with `pynvim`
- Python with `jupyter_client`

After first install of `molten-nvim`, run:

```vim
:UpdateRemotePlugins
```

## Installation

Clone into your Neovim config path:

```bash
git clone https://github.com/<your-username>/<your-repo>.git ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

On first launch, `lazy.nvim` will install plugins automatically.

## Jupyter Workflow

This setup is optimized for notebook-style work inside Neovim:

- `jupytext.nvim` handles notebook/text sync
- `molten-nvim` runs code cells against a Jupyter kernel

Configured Jupyter keymaps:

- `<leader>ji` -> init kernel
- `<leader>jl` -> run current line
- `<leader>jv` -> run visual selection
- `<leader>jr` -> re-run cell
- `<leader>jo` -> open output window
- `<leader>jh` -> hide output
- `<leader>jx` -> clear cell output

## Useful Default Keymaps

### General
- `<leader>sf` -> search files (Telescope)
- `<leader>sg` -> live grep (Telescope)
- `<leader>sh` -> help tags
- `<leader>f` -> format buffer
- `<leader>q` -> diagnostics quickfix list
- `<C-h/j/k/l>` -> move between splits
- `<Esc><Esc>` in terminal mode -> exit terminal mode

### Competitive Programming (in .cpp files)
- `<F5>` -> compile and run with input.txt
- `<F9>` -> compile only (check errors)
- `<leader>cr` -> compile and run
- `<leader>ct` -> create/open test files
- `<leader>cd` -> compare output with expected
- `<leader>cn` -> create new CP file from template

## Optional Kickstart Modules

Additional module files exist under `lua/kickstart/plugins/` (debug, lint, autopairs, neo-tree, extended gitsigns, indent guides), but they are currently commented out in `init.lua`.

To enable any of them, uncomment the corresponding `require 'kickstart.plugins.<name>'` line in `init.lua`.

## Project Structure

```text
.
├── init.lua
├── lazy-lock.json
└── lua
    ├── custom
    │   ├── cp-config.lua       # CP keybindings and utilities
    │   └── plugins
    │       ├── init.lua
    │       └── cp-setup.lua    # CP plugin configuration
    ├── kickstart
    │   ├── health.lua
    │   └── plugins
    └── snippets
        └── cpp.lua             # C++ CP templates
```

## Notes

- Theme is set to `tokyonight-night`.
- Nerd Font icons are disabled by default (`vim.g.have_nerd_font = false`).
- Local C++ snippets are available via LuaSnip in `lua/snippets/cpp.lua`.