# Getting Started

This guide helps you become productive quickly with this Neovim setup. It focuses on practical everyday actions, then moves into the competitive programming workflow this configuration is optimized for.

## What This Config Optimizes For

- Fast editing with sensible defaults and Lua-based configuration
- Search-heavy workflows using Telescope
- C/C++ competitive programming with compile, run, test, compare, and stress-test commands
- Clean customization through modular files in `lua/custom/`

## First Launch Checklist

After installation:

1. Open Neovim: `nvim`
2. Wait for plugins to finish first-time installation
3. Run `:checkhealth`
4. Open plugin UI with `:Lazy`

If all looks good, move to the quick tour below.

## Key Concepts You Should Know

### Leader key

This config sets the leader key to **Space**.

So when docs say `<leader>sf`, press:

1. `Space`
2. `s`
3. `f`

### Filetype-local behavior

Some mappings are active only for specific filetypes:

- C/C++ buffers get CP keymaps like `<F5>`, `<leader>cs`, and `:CPMode`
- Java files can use `:R` to compile and run

Why this design: it keeps global keymaps clean and makes language-specific actions context-aware.

## Quick Tour (5 Minutes)

### Find files and search text

- Find files: `<leader>sf`
- Live grep project text: `<leader>sg`
- Search help docs: `<leader>sh`

Example:

1. Press `<leader>sf` and open `init.lua`
2. Press `<leader>sg` and search for `compile_mode`

This is the fastest way to explore an unfamiliar codebase.

### Move around windows quickly

Use split navigation in normal mode:

- `<C-h>` left
- `<C-j>` down
- `<C-k>` up
- `<C-l>` right

Why this matters: your hands stay on home row while navigating splits.

### Work with diagnostics and formatting

- Open diagnostics list: `<leader>q`
- Format current buffer: `<leader>f`

For C/C++, formatting uses `clang-format` when available.

### Comment/uncomment code

- Toggle comment: `<C-/>` or `<C-_>`

Works in normal mode and visual mode.

## Competitive Programming Workflow

This is the core workflow this configuration is designed for.

### Example: Solve a C++ problem end-to-end

```bash
mkdir -p ~/cp/abc-100
cd ~/cp/abc-100
nvim main.cpp
```

Inside Neovim:

1. Insert snippet template:
   - Enter insert mode
   - Type `cpbasic`
   - Expand snippet
2. Create/open test files:
   - `<leader>t` (creates/opens `input1.txt` and `output1.txt`)
3. Compile and run:
   - `<F5>` or `<leader>cr`
4. Compare your output:
   - `<leader>cd` compares `output.txt` against expected output file
5. Switch compile mode when needed:
   - `<leader>cm` to cycle (`fast` -> `debug` -> `submit`)
   - `<leader>cM` to pick a mode from menu

### Why compile modes exist

- `fast`: quick local iteration with useful warnings
- `debug`: sanitizers and debug symbols for catching undefined behavior
- `submit`: optimized flags and release-style build

Set mode explicitly:

```vim
:CPMode fast
:CPMode debug
:CPMode submit
```

### Stress testing

Command:

```vim
:CPStress [gen.cpp] [brute.cpp] [iterations]
```

Real example:

```vim
:CPStress gen.cpp brute.cpp 500
```

Why this is useful: it catches corner cases by comparing your solution against a trusted brute-force implementation over many generated inputs.

## Java Quick Run

The `:R` command supports Java files too.

Example:

1. Open `Main.java`
2. Run:

```vim
:R
```

It compiles with `javac`, runs with `java`, and uses `input.txt` automatically if present.

## Rust Quick Run

The `:R` command supports Rust files.

Example:

1. Open `main.rs`
2. Run:

```vim
:R
```

Behavior:

- In a Cargo project, it runs `cargo run --bin <target>` for the current file when possible (and uses `input.txt` if present).
- If Cargo has multiple binaries and the target cannot be inferred from the current file, Neovim prompts you to choose one.
- For a standalone `.rs` file, it compiles with `rustc` and runs the produced binary.
- Use `:RCompile` for compile/check only (without running).

Rust keymaps in Rust buffers:

- `<F5>` / `<leader>cr` for run (`:R`)
- `<F9>` / `<leader>cc` for compile/check (`:RCompile`)

## Useful Commands to Remember

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager UI |
| `:checkhealth` | Environment diagnostics |
| `:CPRun` | Compile and run C++ |
| `:CPCompile` | Compile only |
| `:CPTest` | Create/open test files |
| `:CPDiff` | Compare `output.txt` with expected output |
| `:CPClear` | Delete generated artifacts: `input*.txt`, `output*.txt`, `expected*.txt` (including numbered files), and current-file executable |
| `:CPStress ...` | Stress test solution |
| `:R` | Compile and run current C/C++/Java/Rust file |
| `:RCompile` | Compile/check current C/C++/Java/Rust file |

## Next Step

After this quick start, continue with:

- `docs/keymaps.md` for full keybinding reference
- `docs/plugins.md` for plugin architecture and purpose
- `docs/customization.md` to tailor the setup to your workflow
