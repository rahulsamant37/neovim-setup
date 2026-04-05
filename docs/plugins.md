# Plugins

This configuration uses `lazy.nvim` as its plugin manager and keeps plugin definitions close to the behavior they implement. This makes the setup easier to maintain and easier to extend.

## How Plugin Loading Works

1. `init.lua` bootstraps `lazy.nvim` automatically if it is missing.
2. Core plugin specs are declared in `init.lua`.
3. Custom plugin specs are imported from `lua/custom/plugins/*.lua`.

Why this structure is useful:

- Core editor behavior stays centralized.
- Personal extensions stay modular and merge-friendly.

## Enabled by Default

| Plugin | Purpose | Config Location | Notes |
| --- | --- | --- | --- |
| `folke/lazy.nvim` | Plugin manager | `init.lua` (bootstrap section) | Auto-installs on first launch |
| `lewis6991/gitsigns.nvim` | Git signs in gutter | `init.lua` | Base signs config is active |
| `nvim-telescope/telescope.nvim` | Fuzzy finding and search | `init.lua` | Main picker for files, grep, diagnostics |
| `nvim-lua/plenary.nvim` | Utility dependency | Telescope + todo-comments | Shared helper library |
| `nvim-telescope/telescope-fzf-native.nvim` | Faster Telescope sorting | Telescope deps | Built only if `make` exists |
| `nvim-telescope/telescope-ui-select.nvim` | Better UI for selections | Telescope deps | Integrates with Telescope themes |
| `nvim-tree/nvim-web-devicons` | File icons | Telescope deps | Enabled only if Nerd Font is enabled |
| `neovim/nvim-lspconfig` | LSP client configuration | `init.lua`, `lua/custom/plugins/cp-setup.lua` | Core LSP + custom `clangd` tuning |
| `j-hui/fidget.nvim` | LSP progress UI | LSP dependency | Lightweight status updates |
| `stevearc/conform.nvim` | Formatting framework | `init.lua` | `<leader>f` formatter entry point |
| `saghen/blink.cmp` | Completion engine | `init.lua` | Completion sources: LSP, path, snippets |
| `L3MON4D3/LuaSnip` | Snippet engine | Blink dependency + snippet loader | Loads snippets from `lua/snippets` |
| `folke/tokyonight.nvim` | Colorscheme | `init.lua` | Uses `tokyonight-night` by default |
| `folke/todo-comments.nvim` | Highlight TODO/FIXME notes | `init.lua` | Signs disabled in this config |
| `nvim-mini/mini.nvim` | Text objects, surround, statusline | `init.lua` | Uses `mini.ai`, `mini.surround`, `mini.statusline` |
| `nvim-treesitter/nvim-treesitter` | Syntax parsing and tree-based features | `init.lua` | Parser install dir adjusted for Neovim `0.11` |
| `windwp/nvim-autopairs` | Auto pair insertion | `lua/kickstart/plugins/autopairs.lua` | Loads on `InsertEnter` |
| `tpope/vim-fugitive` | Git command integration | `lua/custom/plugins/init.lua` | Useful for advanced Git workflows |
| `numToStr/Comment.nvim` | Comment toggling | `lua/custom/plugins/init.lua` | Adds `<C-/>` and `<C-_>` mappings |

## Present but Disabled in Default Setup

These are defined but not enabled in the current default state.

| Plugin | Current State | Why it might be disabled |
| --- | --- | --- |
| `NMAC427/guess-indent.nvim` | `enabled = false` | Explicit indent settings are preferred |
| `folke/which-key.nvim` | `enabled = false` | Reduces startup/UI noise for experienced users |

## Optional Bundled Modules (Not Loaded by Default)

These modules are present under `lua/kickstart/plugins/` and can be enabled by uncommenting imports in `init.lua`.

| Module | Plugin(s) | Purpose |
| --- | --- | --- |
| `debug.lua` | `mfussenegger/nvim-dap`, `rcarriga/nvim-dap-ui`, `jay-babu/mason-nvim-dap.nvim`, `leoluz/nvim-dap-go` | Debugging workflow (DAP) |
| `indent_line.lua` | `lukas-reineke/indent-blankline.nvim` | Indentation guides |
| `lint.lua` | `mfussenegger/nvim-lint` | Linting (markdownlint example included) |
| `neo-tree.lua` | `nvim-neo-tree/neo-tree.nvim` (+ dependencies) | File tree sidebar |
| `gitsigns.lua` | `lewis6991/gitsigns.nvim` (extra mappings) | Advanced hunk keymaps |

## Plugin Configuration Examples

### Example 1: Enable `which-key`

In `init.lua`, change:

```lua
{
  'folke/which-key.nvim',
  enabled = false,
  event = 'VimEnter',
  opts = { ... },
}
```

to:

```lua
{
  'folke/which-key.nvim',
  enabled = true,
  event = 'VimEnter',
  opts = { ... },
}
```

Then run:

```vim
:Lazy sync
```

### Example 2: Enable Neo-tree optional module

In `init.lua`, uncomment:

```lua
require 'kickstart.plugins.neo-tree'
```

Why use this approach: optional modules stay versioned and ready, but do not add startup overhead unless you explicitly opt in.

## Notes for CP Users

- `neovim/nvim-lspconfig` is extended in `lua/custom/plugins/cp-setup.lua` to configure `clangd` with C/C++-friendly defaults.
- Formatting for C/C++ is routed through `conform.nvim` and `clang-format` for predictable style output.
- Snippet templates are powered by `LuaSnip` and loaded from `lua/snippets/cpp.lua`.
