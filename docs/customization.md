# Customization

This guide shows how to safely adapt this Neovim setup to your own workflow without turning your config into a hard-to-maintain monolith.

## Customization Principles

1. Keep core behavior stable in `init.lua`.
2. Add personal plugins in `lua/custom/plugins/`.
3. Keep language/workflow-specific logic isolated (as done with `cp-config.lua`).

Why this works: clean boundaries reduce breakage when updating your config.

## 1) Change UI Defaults

### Enable Nerd Font icons

In `init.lua`, change:

```lua
vim.g.have_nerd_font = false
```

to:

```lua
vim.g.have_nerd_font = true
```

Why: enables icon support in plugins that use file/type icons.

### Switch colorscheme

Current theme plugin is `folke/tokyonight.nvim` with:

```lua
vim.cmd.colorscheme 'tokyonight-night'
```

To switch variant:

```lua
vim.cmd.colorscheme 'tokyonight-moon'
```

Or replace the plugin spec entirely with your preferred theme.

## 2) Add a New Plugin (Recommended Pattern)

Create a new file under `lua/custom/plugins/`.

Example: add `nvim-surround` as a separate custom plugin file.

```lua
-- lua/custom/plugins/surround.lua
---@module 'lazy'
---@type LazySpec
return {
  'kylechui/nvim-surround',
  event = 'VeryLazy',
  opts = {},
}
```

Then sync plugins:

```vim
:Lazy sync
```

Why this pattern is preferred:

- Each plugin has isolated config.
- Easy to remove or debug one plugin at a time.

## 3) Enable Optional Bundled Modules

Several ready-made modules are present in `lua/kickstart/plugins/` but disabled in `init.lua`.

To enable linting, uncomment:

```lua
require 'kickstart.plugins.lint'
```

To enable debugger setup, uncomment:

```lua
require 'kickstart.plugins.debug'
```

Why this is useful: you opt in only to features you actually use.

## 4) Add or Modify Keymaps

### Global keymap example

Add this in `init.lua` near other keymaps:

```lua
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save file' })
```

### Filetype-local keymap example (Python)

```lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.keymap.set('n', '<leader>rr', '<cmd>!python3 %<CR>', {
      buffer = true,
      silent = true,
      desc = 'Run current Python file',
    })
  end,
})
```

Why filetype-local mappings are better: they prevent global keymap overload.

## 5) Customize Competitive Programming Compile Modes

Compile mode flags live in `lua/custom/cp-config.lua` inside `compile_modes`.

Example: add extra warning flags to `fast` mode:

```lua
fast = {
  label = 'FAST',
  flags = '-std=c++23 -O2 -pipe -Wall -Wextra -Wshadow -Wconversion -Wfloat-equal -DLOCAL',
},
```

Switch mode in Neovim:

```vim
:CPMode fast
```

Why compile modes are separated: you can optimize for speed, debugging, or submissions without manually rewriting commands each time.

## 6) Add Your Own C/C++ Snippet

Edit `lua/snippets/c.lua` (for C) or `lua/snippets/cpp.lua` (for C++) and add a snippet entry.

Example snippet:

```lua
ps({ trig = 'cpio', dscr = 'Fast IO helper' }, [[
void fast_io() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
}
]])
```

Reload snippets by restarting Neovim (or reload your snippet module manually).

Why snippets are powerful here: they reduce contest startup time and keep your boilerplate consistent.

## 7) Customize `clangd` Behavior

Edit `lua/custom/plugins/cp-setup.lua`.

Example: add a compile commands directory hint:

```lua
cmd = {
  'clangd',
  '--background-index',
  '--compile-commands-dir=build',
  '--clang-tidy',
  '--header-insertion=iwyu',
}
```

Why this helps: larger projects often keep compile metadata in separate build directories.

## 8) Keep Customizations Maintainable

- Prefer small plugin files over giant inline configs.
- Add clear `desc` fields to keymaps.
- Validate after changes with `:checkhealth` and `:Lazy`.
- Test language-specific changes in real files (for example `.c` or `.cpp`) to confirm filetype-local mappings and commands load as expected.
