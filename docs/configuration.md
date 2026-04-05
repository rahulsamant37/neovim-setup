# Configuration

This guide explains how the configuration is organized, what each file controls, and where to make changes safely.

## Configuration Philosophy

This setup is intentionally split into:

- **Core editor configuration** (options, core keymaps, plugin bootstrap)
- **Custom competitive programming workflow** (compile/run/test/stress features)
- **Modular plugin specs** (easy to add/remove without rewriting large files)

Why this is effective:

- New users can start from sensible defaults.
- Advanced users can modify one area without breaking unrelated parts.

## Folder Structure

```text
.
├── init.lua
├── lazy-lock.json
├── lua
│   ├── custom
│   │   ├── cp-config.lua
│   │   └── plugins
│   │       ├── cp-setup.lua
│   │       └── init.lua
│   ├── kickstart
│   │   ├── health.lua
│   │   └── plugins
│   │       ├── autopairs.lua
│   │       ├── debug.lua
│   │       ├── gitsigns.lua
│   │       ├── indent_line.lua
│   │       ├── lint.lua
│   │       └── neo-tree.lua
│   └── snippets
│       └── cpp.lua
└── README.md
```

## File-by-File Reference

| File | What it controls | Why it exists |
| --- | --- | --- |
| `init.lua` | Global options, keymaps, plugin manager bootstrap, main plugin specs | Single entry point that keeps startup behavior easy to trace |
| `lua/custom/cp-config.lua` | C/C++ compile/run/test/stress workflow, CP commands, CP keymaps | Keeps domain-specific workflow out of general editor config |
| `lua/custom/plugins/init.lua` | Personal plugin additions (Fugitive, Comment.nvim) | Clean extension area with low merge conflict risk |
| `lua/custom/plugins/cp-setup.lua` | `clangd` customization for C/C++ | Keeps CP/LSP tuning separate from general LSP setup |
| `lua/snippets/cpp.lua` | C++ snippet templates (`cpbasic`, `cpfull`, etc.) | Fast contest/problem boilerplate generation |
| `lua/kickstart/health.lua` | Health checks for dependencies | Easier diagnostics via `:checkhealth` |
| `lua/kickstart/plugins/*.lua` | Optional plugin modules | Turn features on/off without deleting code |
| `lazy-lock.json` | Exact plugin versions | Reproducible plugin state across machines |

## Core Options You Should Know

Configured in `init.lua`:

- Leader key is set to space
- Relative line numbers are enabled
- Clipboard sync uses `unnamedplus`
- Search uses smart case behavior
- Split default behavior is right/below
- Default indentation is 4 spaces

Example option changes:

```lua
vim.o.relativenumber = false
vim.o.scrolloff = 5
vim.o.timeoutlen = 500
```

Why change these:

- Lower `scrolloff` if you want more visible code context.
- Lower `timeoutlen` if leader sequences feel too slow.

## Plugin Configuration Layout

The plugin setup in `init.lua` contains:

1. Core plugins (Telescope, LSP, formatting, completion, theme, Treesitter)
2. Optional bundled plugin modules (commented imports under `lua/kickstart/plugins/`)
3. Custom imports via:

```lua
{ import = 'custom.plugins' }
```

Why import from `custom.plugins`:

- You can add plugin files without turning `init.lua` into a monolith.
- Team or personal customizations stay isolated.

## Competitive Programming Configuration

`lua/custom/cp-config.lua` provides:

- Compile modes: `fast`, `debug`, `submit`
- Commands: `:CPRun`, `:CPCompile`, `:CPTest`, `:CPDiff`, `:CPNew`, `:CPStress`, `:CPMode`, `:CPCycleMode`
- File workflow around `input1.txt` / `output1.txt`

Why numbered test files:

- Works naturally with Competitive Companion style workflows.
- Makes it easier to manage multiple sample tests.

Example:

```vim
:CPMode debug
:CPRun
:CPDiff
```

## LSP and Formatting Behavior

### LSP

- Base LSP behavior is in `init.lua`
- `clangd` is customized in `lua/custom/plugins/cp-setup.lua`

The `clangd` setup includes flags for:

- background indexing
- clang-tidy support
- detailed completions
- fallback 4-space style

### Formatting

- Formatting is handled by `conform.nvim`
- `<leader>f` runs manual formatting
- C/C++ uses `clang-format` when available
- Lua uses `stylua` when available

Why C/C++ formatting skips LSP fallback:

- It keeps formatting deterministic for contest code and avoids accidental style drift.

## Snippet System

Snippets are loaded from:

```lua
require('luasnip.loaders.from_lua').load {
  paths = '~/.config/nvim/lua/snippets',
}
```

Available C++ triggers include:

- `cpbasic`
- `cpfull`
- `cpinter`
- `cpext`
- `cpa`
- `basiccpp`

Why multiple templates:

- Different problems need different boilerplate complexity.

## Runtime Command Flow (High-Level)

When Neovim starts:

1. `init.lua` sets options/keymaps
2. `lazy.nvim` bootstraps and loads plugin specs
3. Optional runtime events attach LSP and filetype-local keymaps
4. `custom.cp-config` is loaded to register CP workflows

Understanding this flow helps debug startup issues faster.
