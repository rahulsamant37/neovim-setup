# FAQ

Answers to common questions about this Neovim configuration.

## General

### What Neovim version do I need?

Use **Neovim 0.11 or newer**.

Check version:

```bash
nvim --version
```

Why: this config uses APIs and Treesitter behavior aligned with Neovim `0.11`.

### Can I try this config without replacing my current one?

Yes.

```bash
git clone https://github.com/rahulsamant37/neovim-setup ~/.config/nvim-rahul
NVIM_APPNAME=nvim-rahul nvim
```

Why: `NVIM_APPNAME` lets you run multiple isolated Neovim configs.

### Where should I start reading the config?

Start with:

1. `init.lua`
2. `lua/custom/cp-config.lua`
3. `lua/custom/plugins/`

This gives you the startup flow, CP workflow, and custom plugin layer.

## Plugins and Setup

### First launch did not install plugins correctly. What should I do?

Inside Neovim:

```vim
:Lazy sync
```

Then restart Neovim.

If issues continue, run:

```vim
:checkhealth
```

### Telescope works, but feels slower than expected.

The native sorter plugin (`telescope-fzf-native.nvim`) only builds if `make` is available.

Check:

```bash
make --version
```

Then run `:Lazy sync` again.

### Why are file icons not visible?

Set this in `init.lua`:

```lua
vim.g.have_nerd_font = true
```

And ensure your terminal font is a Nerd Font variant.

## Competitive Programming Workflow

### Why does this config use `input1.txt` and `output1.txt`?

It is designed around numbered test cases (common in Competitive Companion workflows).

Why this helps:

- Easier multi-sample test management
- Better alignment with CP contest habits

### What is the difference between `output.txt` and `output1.txt`?

- `output.txt`: your program's generated output from run commands
- `output1.txt`: expected output (sample answer)

`<leader>cd` / `:CPDiff` compares these files.

### Which command should I use: `<F5>`, `:CPRun`, or `:R`?

- `<F5>` and `:CPRun`: C/C++ compile and run via CP workflow
- `:R`: convenience command that runs C/C++ (delegates to CP workflow), Java, and Rust
- `:CPRunInteractive` (or `<F7>`/`<leader>r` in C/C++ buffers): interactive C/C++ run mode

Use `<F5>` for the fastest CP loop.

### How do I change compile mode?

Use one of:

```vim
:CPMode fast
:CPMode debug
:CPMode submit
:CPCycleMode
```

Or keymaps:

- `<leader>cm` to cycle
- `<leader>cM` to choose from menu

### `:CPStress` fails immediately. Why?

Common reasons:

- Missing `gen.cpp` or `brute.cpp`
- Compilation errors in any of the three sources (solution/generator/brute)

Run with explicit args to avoid path confusion:

```vim
:CPStress gen.cpp brute.cpp 300
```

## LSP, Formatting, and Snippets

### C/C++ completion/diagnostics are missing.

Check that `clangd` exists:

```bash
clangd --version
which clangd
```

`clangd` is enabled only when its executable is available.

### `<leader>f` does not format C/C++.

For this config, C/C++ formatting expects `clang-format`.

Check:

```bash
clang-format --version
```

Install it, then retry.

### Lua formatting is inconsistent.

Install `stylua` so Conform can use it directly. Without it, fallback paths may differ.

### My snippet trigger text stays literal (for example `cpbasic`).

Ensure you expand snippets with your snippet key flow (completion/snippet jump).

Helpful checks:

- `LuaSnip` is installed (`:Lazy`)
- You are in a C++ buffer (`:set filetype?` shows `cpp`)
- Try `<C-s>` (insert mode mapping in C/C++ buffers)

## Troubleshooting and Recovery

### Health check reports warnings. Do I need to fix all of them?

No. Focus on warnings for tools and languages you actually use.

### How can I reset plugin state if things get messy?

From shell:

```bash
rm -rf ~/.local/share/nvim/lazy
nvim +"Lazy sync" +qa
```

This forces a clean plugin reinstall.

### Where should I ask for help if I am stuck?

When asking for help, include:

1. Neovim version (`nvim --version`)
2. Failing command/keymap
3. Output from `:checkhealth`
4. Any error message from `:messages`

That context makes debugging significantly faster.
