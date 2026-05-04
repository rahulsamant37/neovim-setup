# Competitive Programming Setup

This document covers the complete Competitive Programming (CP) workflow built into this Neovim configuration. It is designed to minimize friction during contests by automating compilation, test case management, and stress testing.

## Core Features

- **Test Case Management**: Automatically creates, syncs, and compares input/output files.
- **Multiple Compile Modes**: Switch between Fast (local iteration), Debug (sanitizers), and Submit (release flags) instantly.
- **Stress Testing**: Compare your solution against a brute-force approach across thousands of generated test cases.
- **Snippet Integration**: Drop in C/C++ boilerplates in seconds.
- **Interactive Mode**: Test interactive problems with proper stdin/stdout.

## Architecture

The CP logic is modularized inside `lua/custom/cp/`:

- `config.lua`: State, compile modes, and flags.
- `compiler.lua`: Selection of compilers (`gcc`, `g++`) and execution of builds.
- `runner.lua`: Building, running scripts, and custom interactive flows.
- `testcase.lua`: Test file discovery, diff generation, and cleanup.
- `stress.lua`: Stress testing logic.
- `utils.lua`: Shared file I/O and terminal utilities.
- `init.lua`: Public API re-exports.

Keybindings and Neovim-specific integration (autocmds, commands) live in the wiring file at `lua/custom/plugins/cp.lua`.

---

## 1. Quick Start Workflow

Assume you want to solve a problem named `A`.

1. **Create File**:
   Run `:CPNew` or `nvim A.cpp`.
2. **Insert Template**:
   Enter insert mode, type `cpbasic`, and press `<Tab>` (or `<C-s>`) to expand the snippet.
3. **Open Test Cases**:
   Press `<leader>t` (or `:CPTest`). This automatically creates and opens `input1.txt` and `output1.txt` in horizontal splits. Paste the sample input into `input1.txt` and expected output into `output1.txt`.
4. **Compile and Run**:
   Press `<F5>` (or `<leader>cr`). Your code will run against `input1.txt`, and the results will be written to `output.txt` (which opens in a split).
5. **Compare**:
   Press `<leader>cd` (or `:CPDiff`). A side-by-side split will show your `output.txt` alongside `output1.txt`, highlighting any differences.

---

## 2. Compile Modes

Different phases of solving require different compiler flags. You can change these on the fly.

| Mode | Purpose | Shortcut |
|---|---|---|
| `fast` | Default. Balanced optimization for quick iteration. | `:CPMode fast` |
| `debug` | Adds AddressSanitizer and UndefinedBehaviorSanitizer to catch segfaults. | `:CPMode debug` |
| `submit` | Uses maximum optimization (`-O3`) to simulate actual judge timing. | `:CPMode submit` |

- `<leader>cm` cycles through modes (Fast -> Debug -> Submit).
- `<leader>cM` opens a UI picker to choose a mode.

*Note: Flags are defined in `lua/custom/cp/config.lua`.*

---

## 3. Test Case Management

The setup automatically handles multiple test files if numbered sequentially (e.g., `input1.txt`, `input2.txt`). 

When you press `<F5>`, the runner looks for the **lowest numbered** input file (usually `input1.txt`). If you need to test against `input2.txt`, you can either delete/rename `input1.txt` or run with custom input.

- `<leader>t` (`:CPTest`): Creates/opens `input1.txt` and `output1.txt`.
- `<leader>cd` (`:CPDiff`): Compares `output.txt` (generated) against `output1.txt` (expected).
- `<leader>x` (`:CPClear`): Removes the executable and all `input*.txt`, `output*.txt`, and `expected*.txt` artifacts in the current directory to keep your workspace clean.

---

## 4. Custom Inputs & Interactive Problems

Sometimes you don't want to save a test case to a file, or you are solving an interactive problem.

- **Run with Custom Input**: `<F6>` or `<leader>ci`. Prompts for a file path or an inline string (e.g., `5\n1 2 3 4 5`).
- **Interactive Mode**: `<F7>` or `<leader>r`. Compiles the file **without** `-DLOCAL` (to prevent `freopen` calls if you use them) and drops you into an interactive terminal split to type inputs and view outputs line-by-line.

---

## 5. Stress Testing

When you receive a Wrong Answer but don't know the failing test case, you can stress test your solution.

You need three files in the same directory:
1. `solution.cpp`: Your fast but incorrect solution.
2. `brute.cpp`: A slow but 100% correct brute-force solution.
3. `gen.cpp`: A test case generator that writes to `stdout`.

**Command**:
```vim
:CPStress gen.cpp brute.cpp 1000
```
*(Or use `<leader>cs` which defaults to `gen.cpp`, `brute.cpp`, and 100 iterations).*

**How it works**:
It compiles all three files. Then it loops up to `iterations` times:
1. Runs `gen` -> saves to `input.txt`
2. Runs `brute` with `input.txt` -> saves to `expected.txt`
3. Runs `solution` with `input.txt` -> saves to `output.txt`
4. Compares `expected.txt` and `output.txt`.

It stops at the first mismatch, leaving the failing case in `input.txt`.

---

## 6. Keybinds Reference (C/C++ Buffers)

| Key | Action |
| --- | --- |
| `<F5>` / `<leader>cr` | Compile and run (`:CPRun`) |
| `<F9>` / `<leader>cc` | Compile only (`:CPCompile`) |
| `<F6>` / `<leader>ci` | Run with custom input |
| `<F7>` / `<leader>r`  | Run interactively (`:CPRunInteractive`) |
| `<leader>t` / `<leader>ct` | Create/open test files (`:CPTest`) |
| `<leader>cd` | Compare output with expected (`:CPDiff`) |
| `<leader>x` | Delete CP artifacts (`:CPClear`) |
| `<leader>cs` | Stress test (`:CPStress`) |
| `<leader>cn` | New CP file from snippet (`:CPNew`) |
| `<leader>cm` | Cycle compile mode (`:CPCycleMode`) |
| `<leader>cM` | Menu to pick compile mode |

### Snippets (Insert Mode)
| Key | Action |
| --- | --- |
| `<C-s>` | Expand/jump snippet |

### CP Algorithms Quick Links (Normal Mode)
| Key | Action |
| --- | --- |
| `<leader>ar` | Open CP-Algorithms Roadmap |
| `<leader>aw` | Open Weekly Plan |
| `<leader>al` | Open Read-First List |
| `<leader>aL` | Open Revise List |
