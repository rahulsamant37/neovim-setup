-- Competitive Programming Configuration
-- Keybindings and utilities for fast CP workflow.

local M = {}

local compile_modes = {
  fast = {
    label = 'FAST',
    flags = '-std=c++23 -O2 -pipe -Wall -Wextra -Wshadow -Wconversion -DLOCAL',
  },
  debug = {
    label = 'DEBUG',
    flags = '-std=c++23 -O0 -g3 -Wall -Wextra -Wshadow -Wconversion -DLOCAL -D_GLIBCXX_DEBUG -fsanitize=address,undefined -fno-omit-frame-pointer',
  },
  submit = {
    label = 'SUBMIT',
    flags = '-std=c++23 -O2 -pipe -Wall -Wextra -Wshadow -DNDEBUG',
  },
}

local c_compile_mode_flags = {
  fast = '-std=c17 -O2 -pipe -Wall -Wextra -Wshadow -Wconversion -DLOCAL',
  debug = '-std=c17 -O0 -g3 -Wall -Wextra -Wshadow -Wconversion -DLOCAL -fsanitize=address,undefined -fno-omit-frame-pointer',
  submit = '-std=c17 -O2 -pipe -Wall -Wextra -Wshadow -DNDEBUG',
}

local stress_compile_flags = '-std=c++23 -O2 -pipe -Wall -Wextra -Wshadow'

local compile_mode = vim.g.cp_compile_mode
if not compile_modes[compile_mode] then
  compile_mode = 'fast'
end
vim.g.cp_compile_mode = compile_mode

local function get_mode(mode_name)
  local name = mode_name or compile_mode
  local mode = compile_modes[name]
  if mode then
    return mode, name
  end
  return compile_modes.fast, 'fast'
end

local function get_compile_profile_for_buffer(bufnr, mode_name)
  local mode, selected_mode = get_mode(mode_name)
  local ft = vim.bo[bufnr].filetype

  if ft == 'c' then
    return {
      compiler = 'gcc',
      flags = c_compile_mode_flags[selected_mode] or c_compile_mode_flags.fast,
      label = mode.label,
    }
  end

  return {
    compiler = 'g++',
    flags = mode.flags,
    label = mode.label,
  }
end

local function update_makeprg_for_buffer(bufnr)
  local ft = vim.bo[bufnr].filetype
  if ft ~= 'c' and ft ~= 'cpp' then
    return
  end

  local profile = get_compile_profile_for_buffer(bufnr)
  vim.bo[bufnr].makeprg = string.format('%s %s %% -o %%:r', profile.compiler, profile.flags)
end

local function set_compile_mode(mode_name, silent)
  if not compile_modes[mode_name] then
    vim.notify('Invalid CP mode: ' .. mode_name .. ' (use: fast, debug, submit)', vim.log.levels.ERROR)
    return false
  end

  compile_mode = mode_name
  vim.g.cp_compile_mode = mode_name

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      update_makeprg_for_buffer(bufnr)
    end
  end

  if not silent then
    local mode = get_mode()
    vim.notify('CP compile mode: ' .. mode.label, vim.log.levels.INFO)
  end

  return true
end

local function cycle_compile_mode()
  local order = { 'fast', 'debug', 'submit' }
  local idx = 1
  for i, name in ipairs(order) do
    if name == compile_mode then
      idx = i
      break
    end
  end
  local next_idx = (idx % #order) + 1
  set_compile_mode(order[next_idx])
end

local function get_numbered_test_cases(source_dir)
  local input_files = vim.fn.globpath(source_dir, 'input*.txt', false, true)
  local cases = {}

  for _, file in ipairs(input_files) do
    local name = vim.fn.fnamemodify(file, ':t')
    local idx = name:match('^input(%d+)%.txt$')
    if idx then
      table.insert(cases, tonumber(idx))
    end
  end

  table.sort(cases)
  return cases
end

local function get_primary_input_file(source_dir)
  local cases = get_numbered_test_cases(source_dir)
  for _, idx in ipairs(cases) do
    local candidate = source_dir .. '/input' .. idx .. '.txt'
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  local legacy_input = source_dir .. '/input.txt'
  if vim.fn.filereadable(legacy_input) == 1 then
    return legacy_input
  end

  return nil
end

local function get_expected_output_file(source_dir)
  local cases = get_numbered_test_cases(source_dir)
  for _, idx in ipairs(cases) do
    local candidate = source_dir .. '/output' .. idx .. '.txt'
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  local legacy_expected = source_dir .. '/expected.txt'
  if vim.fn.filereadable(legacy_expected) == 1 then
    return legacy_expected
  end

  return nil
end

local function set_quickfix_from_output(title, output)
  local trimmed = vim.trim(output or '')
  local lines
  if trimmed == '' then
    lines = { 'No compiler output was captured.' }
  else
    lines = vim.split(trimmed, '\n', { plain = true, trimempty = true })
  end

  vim.fn.setqflist({}, 'r', {
    title = title,
    lines = lines,
  })
  vim.cmd.copen()
end

local function open_terminal_script(script)
  vim.cmd.vsplit()
  vim.cmd('terminal sh -c ' .. vim.fn.shellescape(script))
  vim.cmd.startinsert()
end

local function get_cpp_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local source_file = vim.api.nvim_buf_get_name(bufnr)

  if source_file == '' then
    vim.notify('Save the file first!', vim.log.levels.WARN)
    return nil
  end

  if vim.bo[bufnr].modified then
    vim.cmd.write()
  end

  source_file = vim.fn.fnamemodify(source_file, ':p')
  local source_dir = vim.fn.fnamemodify(source_file, ':h')
  local source_base = vim.fn.fnamemodify(source_file, ':t:r')

  return {
    bufnr = bufnr,
    source_file = source_file,
    source_dir = source_dir,
    source_base = source_base,
    binary_path = source_dir .. '/' .. source_base,
    input_file = source_dir .. '/input.txt',
    output_file = source_dir .. '/output.txt',
  }
end

local function compile_source_file(source_file, binary_path, compiler, flags, quickfix_title)
  local compile_cmd = string.format(
    '%s %s %s -o %s 2>&1',
    compiler,
    flags,
    vim.fn.shellescape(source_file),
    vim.fn.shellescape(binary_path)
  )

  local output = vim.fn.system(compile_cmd)
  if vim.v.shell_error ~= 0 then
    set_quickfix_from_output(quickfix_title, output)
    return false
  end

  vim.cmd.cclose()
  return true
end

local function compile_cpp_with_result(notify_success)
  local ctx = get_cpp_context()
  if not ctx then
    return false, nil
  end

  local profile = get_compile_profile_for_buffer(ctx.bufnr)
  local ok = compile_source_file(ctx.source_file, ctx.binary_path, profile.compiler, profile.flags, 'Compilation Errors')

  if ok then
    if notify_success then
      vim.notify('Compilation successful [' .. profile.label .. ']!', vim.log.levels.INFO)
    end
  else
    vim.notify('Compilation failed!', vim.log.levels.ERROR)
  end

  return ok, ctx
end

local function build_run_script(binary_path, input_path, output_path, cleanup_cmd)
  local run_cmd = vim.fn.shellescape(binary_path)
  if input_path then
    run_cmd = run_cmd .. ' < ' .. vim.fn.shellescape(input_path)
  end

  local output_escaped = vim.fn.shellescape(output_path)
  local cleanup = ''
  if cleanup_cmd and cleanup_cmd ~= '' then
    cleanup = cleanup_cmd .. '; '
  end

  return string.format(
    'time %s > %s; code=$?; printf "\\n===== output.txt =====\\n"; [ -f %s ] && cat %s; %sexit $code',
    run_cmd,
    output_escaped,
    output_escaped,
    output_escaped,
    cleanup
  )
end

-- ==================== CP-SPECIFIC OPTIONS ====================
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('cp-filetype-options', { clear = true }),
  pattern = { 'cpp', 'c' },
  callback = function()
    update_makeprg_for_buffer(0)

    -- Set tab width to 4 for C/C++ (common in CP)
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- ==================== QUICK COMPILE & RUN ====================

local function compile_cpp()
  local mode = get_mode()
  vim.notify('Compiling [' .. mode.label .. ']...', vim.log.levels.INFO)
  compile_cpp_with_result(true)
end

local function compile_and_run_cpp()
  local mode, mode_name = get_mode()
  vim.notify('Compiling [' .. mode.label .. ']...', vim.log.levels.INFO)

  local ok, ctx = compile_cpp_with_result(false)
  if not ok or not ctx then
    return
  end

  local selected_input = get_primary_input_file(ctx.source_dir)
  if selected_input and selected_input ~= ctx.input_file then
    -- Keep LOCAL freopen("input.txt") templates working with inputN.txt tests.
    local input_lines = vim.fn.readfile(selected_input)
    vim.fn.writefile(input_lines, ctx.input_file)
  end

  if vim.fn.filereadable(ctx.output_file) == 0 then
    vim.fn.writefile({}, ctx.output_file)
  end

  local run_script = build_run_script(ctx.binary_path, selected_input, ctx.output_file)
  open_terminal_script(run_script)

  local input_label = selected_input and vim.fn.fnamemodify(selected_input, ':t') or 'stdin'
  vim.notify('Running [' .. string.lower(mode_name) .. '] with ' .. input_label .. ' -> output.txt', vim.log.levels.INFO)
end

local function run_with_input()
  local ctx = get_cpp_context()
  if not ctx then
    return
  end

  if vim.fn.filereadable(ctx.binary_path) == 0 then
    vim.notify('Binary not found! Compile first.', vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = 'Enter file path or inline input (use \\n for newline): ' }, function(input)
    if not input or input == '' then
      return
    end

    local selected_input
    local cleanup_cmd = nil
    local source_relative_input = ctx.source_dir .. '/' .. input

    if vim.fn.filereadable(input) == 1 then
      selected_input = vim.fn.fnamemodify(input, ':p')
    elseif vim.fn.filereadable(source_relative_input) == 1 then
      selected_input = source_relative_input
    else
      local temp_input = vim.fn.tempname() .. '.txt'
      local normalized = input:gsub('\\n', '\n')
      vim.fn.writefile(vim.split(normalized, '\n', { plain = true }), temp_input)
      selected_input = temp_input
      cleanup_cmd = 'rm -f ' .. vim.fn.shellescape(temp_input)
    end

    if selected_input ~= ctx.input_file then
      local input_lines = vim.fn.readfile(selected_input)
      vim.fn.writefile(input_lines, ctx.input_file)
    end

    if vim.fn.filereadable(ctx.output_file) == 0 then
      vim.fn.writefile({}, ctx.output_file)
    end

    local run_script = build_run_script(ctx.binary_path, selected_input, ctx.output_file, cleanup_cmd)
    open_terminal_script(run_script)

    vim.notify('Running with custom input -> output.txt', vim.log.levels.INFO)
  end)
end

local function prompt_compile_mode()
  vim.ui.select({ 'fast', 'debug', 'submit' }, { prompt = 'Select CP compile mode:' }, function(choice)
    if choice then
      set_compile_mode(choice)
    end
  end)
end

-- Run compiled binary interactively (prompt for input; do NOT auto-use input1.txt)
-- Run compiled binary interactively: compile, then open right-side stacked
-- input/output panes. Left stays as the source file; top-right is editable
-- input, bottom-right shows the program output. Use <F7> or <leader>r in
-- the input pane to run the program (output replaces bottom-right contents).
local function run_interactive()
  -- Get context and compile WITHOUT -DLOCAL so program reads from stdin.
  local ctx = get_cpp_context()
  if not ctx then
    return
  end

  local profile = get_compile_profile_for_buffer(ctx.bufnr)
  local interactive_flags = profile.flags:gsub('%-DLOCAL%s*', '')

  local ok = compile_source_file(ctx.source_file, ctx.binary_path, profile.compiler, interactive_flags, 'RunCpp (interactive) compile errors')
  if not ok then
    vim.notify('RunCpp: interactive compilation failed. See quickfix list.', vim.log.levels.ERROR)
    return
  end

  -- Build a wrapper script that runs the binary (interactive), then
  -- prints a marker and waits for a key so the terminal doesn't immediately
  -- vanish after the program exits.
  local bin = vim.fn.shellescape(ctx.binary_path)
  local wrapper = string.format('%s; code=$?; echo; echo "[Process exited $code]"; read -n 1 -s -r -p "Press any key to close..."', bin)

  vim.cmd('vsplit')
  -- Use bash -lc so the wrapper runs in a shell and the read builtin is available.
  vim.cmd('terminal bash -lc ' .. vim.fn.shellescape(wrapper))
  vim.cmd.startinsert()
end

-- Create/open test files using Competitive Companion naming.
local function create_test_files()
  local ctx = get_cpp_context()
  if not ctx then
    return
  end

  local original_win = vim.api.nvim_get_current_win()
  local numbered_cases = get_numbered_test_cases(ctx.source_dir)

  local case_id = 1
  if #numbered_cases > 0 then
    case_id = numbered_cases[1]
  end

  local input_file = ctx.source_dir .. '/input' .. case_id .. '.txt'
  local expected_file = ctx.source_dir .. '/output' .. case_id .. '.txt'

  if vim.fn.filereadable(input_file) == 0 then
    vim.fn.writefile({}, input_file)
  end
  if vim.fn.filereadable(expected_file) == 0 then
    vim.fn.writefile({}, expected_file)
  end

  vim.cmd('split ' .. vim.fn.fnameescape(input_file))
  vim.cmd('vsplit ' .. vim.fn.fnameescape(expected_file))

  if vim.api.nvim_win_is_valid(original_win) then
    vim.api.nvim_set_current_win(original_win)
  end

  vim.notify(string.format('Test files ready (input%d.txt + output%d.txt)!', case_id, case_id), vim.log.levels.INFO)
end

-- Compare output.txt with expected output.
local function compare_output()
  local ctx = get_cpp_context()
  if not ctx then
    return
  end

  local expected_file = get_expected_output_file(ctx.source_dir)

  if vim.fn.filereadable(ctx.output_file) == 0 then
    vim.notify('output.txt not found!', vim.log.levels.ERROR)
    return
  end
  if not expected_file then
    vim.notify('Expected output not found! Create output1.txt (or expected.txt legacy).', vim.log.levels.ERROR)
    return
  end

  vim.cmd('tabnew')
  vim.cmd('edit ' .. vim.fn.fnameescape(ctx.output_file))
  vim.cmd('vsplit ' .. vim.fn.fnameescape(expected_file))
  vim.cmd.windo('diffthis')

  vim.notify('Comparing output.txt with ' .. vim.fn.fnamemodify(expected_file, ':t') .. '...', vim.log.levels.INFO)
end

-- Delete generated local artifacts while preserving source files.
local function clear_test_residue()
  local ctx = get_cpp_context()
  if not ctx then
    return
  end

  local patterns = {
    'input*.txt',
    'output*.txt',
    'expected*.txt',
    'intput*.txt',
    'ouput*.txt',
  }

  local candidates = {}
  for _, pattern in ipairs(patterns) do
    local matches = vim.fn.globpath(ctx.source_dir, pattern, false, true)
    for _, path in ipairs(matches) do
      table.insert(candidates, path)
    end
  end

  if ctx.binary_path ~= ctx.source_file then
    table.insert(candidates, ctx.binary_path)
  end

  local seen = {}
  local removed = {}
  for _, file_path in ipairs(candidates) do
    if not seen[file_path] then
      seen[file_path] = true

      if vim.fn.getftype(file_path) == 'file' then
        local should_delete = true

        -- Only remove the compiled target when it is actually executable.
        if file_path == ctx.binary_path then
          should_delete = vim.fn.executable(file_path) == 1
        end

        if should_delete and vim.fn.delete(file_path) == 0 then
          table.insert(removed, vim.fn.fnamemodify(file_path, ':t'))
        end
      end
    end
  end

  if #removed == 0 then
    vim.notify('No generated CP artifacts found to delete.', vim.log.levels.INFO)
    return
  end

  vim.notify('Deleted: ' .. table.concat(removed, ', '), vim.log.levels.INFO)
end

-- Create new CP file from template.
local function new_cp_file()
  vim.ui.input({ prompt = 'Enter filename (without .cpp): ' }, function(filename)
    if not filename then
      return
    end

    filename = vim.trim(filename)
    if filename == '' then
      return
    end

    local filepath = filename
    if not filepath:match('%.cpp$') then
      filepath = filepath .. '.cpp'
    end

    vim.cmd('edit ' .. vim.fn.fnameescape(filepath))

    -- Place cpbasic trigger and expand it immediately when LuaSnip is available.
    if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'cpbasic' })
    else
      vim.api.nvim_buf_set_lines(0, 0, 0, false, { 'cpbasic' })
    end

    vim.api.nvim_win_set_cursor(0, { 1, 7 })
    vim.schedule(function()
      local ok, luasnip = pcall(require, 'luasnip')
      vim.cmd.startinsert()
      if ok and luasnip.expandable() then
        luasnip.expand()
      else
        vim.notify('Inserted cpbasic trigger. Press <Tab> to expand snippet.', vim.log.levels.WARN)
      end
    end)

    vim.notify('Created ' .. filepath, vim.log.levels.INFO)
  end)
end

-- Stress test usage:
-- :CPStress [generator.cpp] [brute.cpp] [iterations]
local function stress_test(opts)
  opts = opts or {}
  local args = opts.fargs or {}

  local ctx = get_cpp_context()
  if not ctx then
    return
  end

  local generator_src = args[1] and vim.fn.fnamemodify(args[1], ':p') or (ctx.source_dir .. '/gen.cpp')
  local brute_src = args[2] and vim.fn.fnamemodify(args[2], ':p') or (ctx.source_dir .. '/brute.cpp')
  local iterations = tonumber(args[3]) or 200

  if iterations < 1 then
    vim.notify('Iterations must be >= 1.', vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(generator_src) == 0 then
    vim.notify('Generator source not found: ' .. generator_src, vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(brute_src) == 0 then
    vim.notify('Brute source not found: ' .. brute_src, vim.log.levels.ERROR)
    return
  end

  local mode = get_mode()
  -- Stress testing must avoid LOCAL freopen redirection to compare stdin/stdout correctly.
  local solution_flags = mode.flags:gsub('%-DLOCAL%s*', '')
  local solution_bin = ctx.source_dir .. '/.stress_solution'
  local generator_bin = ctx.source_dir .. '/.stress_generator'
  local brute_bin = ctx.source_dir .. '/.stress_brute'

  vim.notify('Compiling stress-test binaries...', vim.log.levels.INFO)

  if not compile_source_file(ctx.source_file, solution_bin, 'g++', solution_flags, 'Stress Test: solution compile errors') then
    vim.notify('Stress test aborted: solution compilation failed.', vim.log.levels.ERROR)
    return
  end

  if not compile_source_file(generator_src, generator_bin, 'g++', stress_compile_flags, 'Stress Test: generator compile errors') then
    vim.notify('Stress test aborted: generator compilation failed.', vim.log.levels.ERROR)
    return
  end

  if not compile_source_file(brute_src, brute_bin, 'g++', stress_compile_flags, 'Stress Test: brute compile errors') then
    vim.notify('Stress test aborted: brute compilation failed.', vim.log.levels.ERROR)
    return
  end

  local stress_input = ctx.source_dir .. '/.stress_input.txt'
  local stress_output = ctx.source_dir .. '/.stress_output.txt'
  local stress_expected = ctx.source_dir .. '/.stress_expected.txt'
  local stress_diff = ctx.source_dir .. '/.stress_diff.txt'

  local script = string.format(
    [[
i=1
max=%d
while [ "$i" -le "$max" ]; do
  %s > %s || exit 2
  %s < %s > %s || exit 3
  %s < %s > %s || exit 4
  if ! diff -u %s %s > %s; then
    echo "Mismatch on test #$i"
    echo "Input:"
    cat %s
    echo
    echo "Diff:"
    cat %s
    exit 1
  fi
  echo "Passed test #$i"
  i=$((i + 1))
done
echo "All stress tests passed: %d"
]],
    iterations,
    vim.fn.shellescape(generator_bin),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(solution_bin),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(stress_output),
    vim.fn.shellescape(brute_bin),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(stress_expected),
    vim.fn.shellescape(stress_expected),
    vim.fn.shellescape(stress_output),
    vim.fn.shellescape(stress_diff),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(stress_diff),
    iterations
  )

  open_terminal_script(script)
  vim.notify('Stress test started (' .. iterations .. ' iterations).', vim.log.levels.INFO)
end

local function cpalg_src_dir()
  return vim.env.CPALG_SRC or (vim.env.HOME .. '/github/cp-algorithms/src')
end

local function open_cpalg_file(relative_path)
  local path = cpalg_src_dir() .. '/' .. relative_path

  if vim.fn.filereadable(path) == 0 then
    vim.notify('CP-Algorithms file not found: ' .. path, vim.log.levels.WARN)
    return
  end

  vim.cmd.edit(vim.fn.fnameescape(path))
end

-- ==================== KEYBINDINGS ====================

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('cp-filetype-keymaps', { clear = true }),
  pattern = { 'cpp', 'c' },
  callback = function()
    local opts = { buffer = true, silent = true }

    -- Compile and run
    vim.keymap.set('n', '<F5>', compile_and_run_cpp, vim.tbl_extend('force', opts, { desc = 'Compile and Run' }))
    vim.keymap.set('n', '<leader>cr', compile_and_run_cpp, vim.tbl_extend('force', opts, { desc = '[C]ompile and [R]un' }))

    -- Compile only
    vim.keymap.set('n', '<F9>', compile_cpp, vim.tbl_extend('force', opts, { desc = 'Compile Only' }))
    vim.keymap.set('n', '<leader>cc', compile_cpp, vim.tbl_extend('force', opts, { desc = '[C]ompile [C]heck' }))

    -- Run with custom input
    vim.keymap.set('n', '<F6>', run_with_input, vim.tbl_extend('force', opts, { desc = 'Run with Input' }))
    vim.keymap.set('n', '<leader>ci', run_with_input, vim.tbl_extend('force', opts, { desc = '[C]ustom [I]nput' }))
    vim.keymap.set('n', '<leader>r', run_interactive, vim.tbl_extend('force', opts, { desc = 'Run interactively (:CPRunInteractive)' }))
    vim.keymap.set('n', '<F7>', run_interactive, vim.tbl_extend('force', opts, { desc = 'Run interactively (:CPRunInteractive)' }))

    -- Test file management
    vim.keymap.set('n', '<leader>t', create_test_files, vim.tbl_extend('force', opts, { desc = '[T]est files' }))
    vim.keymap.set('n', '<leader>ct', create_test_files, vim.tbl_extend('force', opts, { desc = '[C]reate [T]est files' }))
    vim.keymap.set('n', '<leader>cd', compare_output, vim.tbl_extend('force', opts, { desc = '[C]ompare [D]iff' }))
    vim.keymap.set('n', '<leader>x', clear_test_residue, vim.tbl_extend('force', opts, { desc = 'Delete CP artifacts (input*/output*/expected* + exe)' }))

    -- New CP file and stress test
    vim.keymap.set('n', '<leader>cn', new_cp_file, vim.tbl_extend('force', opts, { desc = '[C]reate [N]ew CP file' }))
    vim.keymap.set('n', '<leader>cs', stress_test, vim.tbl_extend('force', opts, { desc = '[C]P [S]tress test' }))

    -- Compile mode controls
    vim.keymap.set('n', '<leader>cm', cycle_compile_mode, vim.tbl_extend('force', opts, { desc = '[C]ycle compile [M]ode' }))
    vim.keymap.set('n', '<leader>cM', prompt_compile_mode, vim.tbl_extend('force', opts, { desc = 'Pick compile mode' }))

    -- Quick snippet trigger in insert mode
    vim.keymap.set('i', '<C-s>', function()
      local ok, luasnip = pcall(require, 'luasnip')
      if ok and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, vim.tbl_extend('force', opts, { desc = 'Expand/jump snippet' }))
  end,
})

-- Global keybinding
vim.keymap.set('n', '<leader>cp', ':edit ~/.config/nvim/lua/custom/cp-config.lua<CR>', { desc = 'Edit [C][P] config' })
vim.keymap.set('n', '<leader>ar', function()
  open_cpalg_file('essential_learning_path.md')
end, { desc = '[A]lgorithms [R]oadmap' })
vim.keymap.set('n', '<leader>aw', function()
  open_cpalg_file('essential_weekly_plan.md')
end, { desc = '[A]lgorithms [W]eekly plan' })
vim.keymap.set('n', '<leader>al', function()
  open_cpalg_file('essential_read_first_order.txt')
end, { desc = '[A]lgorithms [L]ist (read first)' })
vim.keymap.set('n', '<leader>aL', function()
  open_cpalg_file('essential_revise_later_order.txt')
end, { desc = '[A]lgorithms revise [L]ist' })

-- ==================== COMMANDS ====================

vim.api.nvim_create_user_command('CPRun', compile_and_run_cpp, { desc = 'Compile and run C++ file' })
vim.api.nvim_create_user_command('CPRunInteractive', run_interactive, { desc = 'Run compiled binary interactively (prompt for input; does NOT auto-use input1.txt)' })
vim.api.nvim_create_user_command('CPCompile', compile_cpp, { desc = 'Compile C++ file' })
vim.api.nvim_create_user_command('CPTest', create_test_files, { desc = 'Create/open test files' })
vim.api.nvim_create_user_command('CPDiff', compare_output, { desc = 'Compare output.txt with expected output' })
vim.api.nvim_create_user_command('CPClear', clear_test_residue, { desc = 'Delete CP artifacts (input*/output*/expected* + executable)' })
vim.api.nvim_create_user_command('CPNew', new_cp_file, { desc = 'Create new CP file from template' })
vim.api.nvim_create_user_command('CPStress', stress_test, {
  nargs = '*',
  desc = 'Stress test: :CPStress [generator.cpp] [brute.cpp] [iterations]',
})
vim.api.nvim_create_user_command('CPMode', function(opts)
  set_compile_mode(vim.trim(opts.args))
end, {
  nargs = 1,
  complete = function()
    return { 'fast', 'debug', 'submit' }
  end,
  desc = 'Set compile mode: fast|debug|submit',
})
vim.api.nvim_create_user_command('CPCycleMode', cycle_compile_mode, { desc = 'Cycle compile mode' })
vim.api.nvim_create_user_command('CPARoadmap', function()
  open_cpalg_file('essential_learning_path.md')
end, { desc = 'Open CP-Algorithms essential roadmap' })
vim.api.nvim_create_user_command('CPAWeeklyPlan', function()
  open_cpalg_file('essential_weekly_plan.md')
end, { desc = 'Open CP-Algorithms weekly plan' })
vim.api.nvim_create_user_command('CPAReadList', function()
  open_cpalg_file('essential_read_first_order.txt')
end, { desc = 'Open CP-Algorithms read-first list' })
vim.api.nvim_create_user_command('CPAReviseList', function()
  open_cpalg_file('essential_revise_later_order.txt')
end, { desc = 'Open CP-Algorithms revise-later list' })

-- ==================== AUTO-COMMANDS ====================

-- Auto-create input1.txt/output1.txt when opening a new .cpp file.
vim.api.nvim_create_autocmd('BufNewFile', {
  group = vim.api.nvim_create_augroup('cp-new-cpp-files', { clear = true }),
  pattern = '*.cpp',
  callback = function()
    local source_dir = vim.fn.expand('%:p:h')
    local input_file = source_dir .. '/input1.txt'
    local expected_file = source_dir .. '/output1.txt'

    if vim.fn.filereadable(input_file) == 0 then
      vim.fn.writefile({}, input_file)
    end

    if vim.fn.filereadable(expected_file) == 0 then
      vim.fn.writefile({}, expected_file)
    end
  end,
})

set_compile_mode(compile_mode, true)

M.compile_and_run = compile_and_run_cpp
M.compile_only = compile_cpp
M.create_test_files = create_test_files
M.compare_output = compare_output
M.clear_test_residue = clear_test_residue
M.new_cp_file = new_cp_file
M.stress_test = stress_test
M.set_compile_mode = set_compile_mode
M.cycle_compile_mode = cycle_compile_mode

return M
