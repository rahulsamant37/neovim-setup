# Keymaps

This document lists the most important keybindings in this Neovim configuration, grouped by workflow.

## Notation

- `<leader>` = `Space`
- `N` = normal mode
- `I` = insert mode
- `V` = visual mode
- `T` = terminal mode

## Core Editor Keymaps

| Mode | Key | Action |
| --- | --- | --- |
| N | `<Esc>` | Clear search highlight |
| N | `<leader>q` | Open diagnostic quickfix list |
| T | `<Esc><Esc>` | Exit terminal mode |
| N | `<leader>f` | Format current buffer |
| N | `<leader>-` | Open file explorer (`:Ex`) |

Why these matter: they remove frequent friction points (clearing highlights, jumping to errors, formatting, and file navigation).

## Window Navigation

| Mode | Key | Action |
| --- | --- | --- |
| N | `<C-h>` | Focus left split |
| N | `<C-j>` | Focus lower split |
| N | `<C-k>` | Focus upper split |
| N | `<C-l>` | Focus right split |

Example:

1. Open two vertical splits.
2. Use `<C-h>` and `<C-l>` to switch between them without leaving normal mode.

## Buffer Navigation (Same Window)

These are custom mappings added for easier same-window buffer flow.

| Mode | Key | Action |
| --- | --- | --- |
| N | `<leader>be` | New empty buffer in same window |
| N | `<leader>bl` | List buffers |
| N | `<leader>bn` | Next buffer |
| N | `<leader>bp` | Previous buffer |
| N | `<leader>bb` | Last buffer |
| N | `<leader>bd` | Delete current buffer |
| N | `<S-l>` | Next buffer |
| N | `<S-h>` | Previous buffer |
| N | `]b` | Next buffer |
| N | `[b` | Previous buffer |

Quick way to remember:

1. Use `<leader>be` to create a fresh buffer.
2. Move with `<S-h>` and `<S-l>`.
3. Close with `<leader>bd` when done.

## Search and Navigation (Telescope)

| Mode | Key | Action |
| --- | --- | --- |
| N | `<leader>sh` | Search help tags |
| N | `<leader>sk` | Search keymaps |
| N | `<leader>sf` | Find files |
| N | `<leader>sg` | Live grep project |
| N/V | `<leader>sw` | Search current word |
| N | `<leader>sd` | Search diagnostics |
| N | `<leader>ss` | Telescope builtin picker list |
| N | `<leader>sr` | Resume previous picker |
| N | `<leader>s.` | Recent files |
| N | `<leader>sc` | Commands |
| N | `<leader><leader>` | Open buffers list |
| N | `<leader>/` | Fuzzy search current buffer |
| N | `<leader>s/` | Live grep only open files |
| N | `<leader>sn` | Search Neovim config files |

Practical example:

1. Press `<leader>sg`
2. Search `CPMode`
3. Jump directly to command definitions

## LSP Keymaps

These are available when an LSP server is attached to the buffer.

| Mode | Key | Action |
| --- | --- | --- |
| N | `grn` | Rename symbol |
| N/V | `gra` | Code action |
| N | `grD` | Go to declaration |
| N | `grr` | Find references (Telescope) |
| N | `gri` | Go to implementation (Telescope) |
| N | `grd` | Go to definition (Telescope) |
| N | `grt` | Go to type definition (Telescope) |
| N | `gO` | Document symbols |
| N | `gW` | Workspace symbols |
| N | `<leader>th` | Toggle inlay hints (if supported) |

Why split across Telescope and native LSP actions:

- Telescope-based actions are great when multiple results exist.
- Direct LSP actions are fast for single-target operations.

## Editing Productivity

### Move lines or selection

| Mode | Key | Action |
| --- | --- | --- |
| N | `<A-j>` | Move current line down |
| N | `<A-k>` | Move current line up |
| I | `<A-j>` | Move current line down |
| I | `<A-k>` | Move current line up |
| V | `<A-j>` | Move selection down |
| V | `<A-k>` | Move selection up |

### Duplicate lines or selection

| Mode | Key | Action |
| --- | --- | --- |
| N | `<A-S-Down>` | Duplicate line down |
| N | `<A-S-Up>` | Duplicate line up |
| I | `<A-S-Down>` | Duplicate line down |
| I | `<A-S-Up>` | Duplicate line up |
| V | `<A-S-Down>` | Duplicate selection down |
| V | `<A-S-Up>` | Duplicate selection up |

### Smart brace expansion

| Mode | Key | Action |
| --- | --- | --- |
| I | `<CR>` | If cursor is between `{}`: create new indented line block |

Why this exists: writing C/C++ blocks becomes faster with fewer manual edits.

## Comment Toggle

| Mode | Key | Action |
| --- | --- | --- |
| N | `<C-/>` or `<C-_>` | Toggle comment for current line |
| V | `<C-/>` or `<C-_>` | Toggle comment for selected lines |

Note: terminals differ in how they send Ctrl-slash, so both mappings are included.

## Competitive Programming Keymaps (C/C++ Buffers)

These mappings are filetype-local for `c` and `cpp` buffers.

| Mode | Key | Action |
| --- | --- | --- |
| N | `<F5>` | Compile and run |
| N | `<leader>cr` | Compile and run |
| N | `<F9>` | Compile only |
| N | `<leader>cc` | Compile check |
| N | `<F6>` | Run compiled binary with custom input |
| N | `<leader>ci` | Run with custom input |
| N | `<F7>` | Run compiled binary interactively (C/C++) |
| N | `<leader>r` | Run compiled binary interactively (C/C++) |
| N | `<leader>t` | Create/open test files |
| N | `<leader>ct` | Create/open test files |
| N | `<leader>cd` | Compare output with expected output |
| N | `<leader>x` | Delete generated artifacts: input*.txt, output*.txt, expected*.txt (including numbered files), and current-file executable |
| N | `<leader>cn` | Create new CP file from snippet |
| N | `<leader>cs` | Start stress test |
| N | `<leader>cm` | Cycle compile mode |
| N | `<leader>cM` | Choose compile mode from menu |
| I | `<C-s>` | Expand/jump LuaSnip snippet |

Global helper mapping:

| Mode | Key | Action |
| --- | --- | --- |
| N | `<leader>cp` | Open CP config file |

### CP keymap example

1. Open `main.cpp`
2. Press `<leader>t` to open `input1.txt` and `output1.txt`
3. Press `<F5>` to compile and run
4. Press `<leader>cd` to compare generated `output.txt` with expected output

## Rust Run and Compile Keymaps (Rust Buffers)

These mappings are filetype-local for `rust` buffers.

| Mode | Key | Action |
| --- | --- | --- |
| N | `<F5>` | Compile and run (`:R`) |
| N | `<leader>cr` | Compile and run (`:R`) |
| N | `<F9>` | Compile/check (`:RCompile`) |
| N | `<leader>cc` | Compile/check (`:RCompile`) |

Rust run behavior:

- Inside a Cargo project: uses `cargo run --bin <target>` when target can be inferred from the current file
- If target inference is ambiguous in a multi-bin workspace: prompts you to select a binary
- Standalone `.rs` file: uses `rustc` compile + run

## Commands (Related, Not Keymaps)

| Command | Action |
| --- | --- |
| `:CPRun` | Compile and run C++ |
| `:CPCompile` | Compile only |
| `:CPRunInteractive` | Run C/C++ binary interactively |
| `:CPTest` | Create/open test files |
| `:CPDiff` | Compare output with expected file |
| `:CPClear` | Delete generated artifacts: input*.txt, output*.txt, expected*.txt (including numbered files), and current-file executable |
| `:CPNew` | New C++ file from template |
| `:CPStress ...` | Stress test solution |
| `:CPMode fast|debug|submit` | Set compile mode |
| `:CPCycleMode` | Cycle compile mode |
| `:R` | Compile and run current C/C++/Java/Rust file |
| `:RCompile` | Compile/check current C/C++/Java/Rust file |
