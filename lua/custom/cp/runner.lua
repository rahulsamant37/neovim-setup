-- Build-and-run, custom input, interactive mode, and new file creation.

local config = require('custom.cp.config')
local utils = require('custom.cp.utils')
local compiler = require('custom.cp.compiler')
local testcase = require('custom.cp.testcase')

local M = {}

--- Build a shell script that runs a binary and displays output.
---@param binary_path string
---@param input_path? string
---@param output_path string
---@param cleanup_cmd? string
---@return string script
function M.build_run_script(binary_path, input_path, output_path, cleanup_cmd)
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

--- Compile only (no run).
function M.compile_only()
  local mode = config.get_compile_mode()
  vim.notify('Compiling [' .. mode.label .. ']...', vim.log.levels.INFO)
  compiler.compile_cpp_with_result(true)
end

--- Compile and run the current C/C++ file.
function M.compile_and_run()
  local mode, mode_name = config.get_compile_mode()
  vim.notify('Compiling [' .. mode.label .. ']...', vim.log.levels.INFO)

  local ok, ctx = compiler.compile_cpp_with_result(false)
  if not ok or not ctx then
    return
  end

  local selected_input = testcase.get_primary_input_file(ctx.source_dir)
  -- Keep LOCAL freopen("input.txt") templates working with inputN.txt tests.
  utils.sync_input_file(selected_input, ctx.input_file)

  utils.ensure_file_exists(ctx.output_file)

  local run_script = M.build_run_script(ctx.binary_path, selected_input, ctx.output_file)
  utils.open_terminal_script(run_script)

  local input_label = selected_input and vim.fn.fnamemodify(selected_input, ':t') or 'stdin'
  vim.notify('Running [' .. string.lower(mode_name) .. '] with ' .. input_label .. ' -> output.txt', vim.log.levels.INFO)
end

--- Run a compiled binary with custom input (file path or inline text).
function M.run_with_input()
  local ctx = utils.get_cpp_context()
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

    utils.sync_input_file(selected_input, ctx.input_file)

    utils.ensure_file_exists(ctx.output_file)

    local run_script = M.build_run_script(ctx.binary_path, selected_input, ctx.output_file, cleanup_cmd)
    utils.open_terminal_script(run_script)

    vim.notify('Running with custom input -> output.txt', vim.log.levels.INFO)
  end)
end

--- Run compiled binary interactively (compile without -DLOCAL, prompt for stdin).
function M.run_interactive()
  local ctx = utils.get_cpp_context()
  if not ctx then
    return
  end

  local profile = compiler.get_compile_profile_for_buffer(ctx.bufnr)
  local interactive_flags = utils.strip_local_define(profile.flags)

  local ok = compiler.compile_source_file(ctx.source_file, ctx.binary_path, profile.compiler, interactive_flags, 'CPRun (interactive) compile errors')
  if not ok then
    vim.notify('CPRun: interactive compilation failed. See quickfix list.', vim.log.levels.ERROR)
    return
  end

  local bin = vim.fn.shellescape(ctx.binary_path)
  local wrapper = string.format('%s; code=$?; echo; echo "[Process exited $code]"; read -n 1 -s -r -p "Press any key to close..."', bin)

  vim.cmd('vsplit')
  vim.cmd('terminal bash -lc ' .. vim.fn.shellescape(wrapper))
  vim.cmd.startinsert()
end

--- Create a new CP file from a snippet template.
function M.new_cp_file()
  local default_extension = vim.bo.filetype == 'c' and 'c' or 'cpp'
  vim.ui.input({ prompt = 'Enter filename (without .' .. default_extension .. '): ' }, function(filename)
    if not filename then
      return
    end

    filename = vim.trim(filename)
    if filename == '' then
      return
    end

    local filepath = filename
    if not filepath:match('%.[%w_]+$') then
      filepath = filepath .. '.' .. default_extension
    end

    local extension = vim.fn.fnamemodify(filepath, ':e'):lower()
    local is_supported = extension == 'c' or extension == 'cpp' or extension == 'cc' or extension == 'cxx'
    if not is_supported then
      vim.notify('CPNew supports .c, .cpp, .cc, and .cxx files.', vim.log.levels.ERROR)
      return
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
      local luasnip_ok, luasnip = pcall(require, 'luasnip')
      vim.cmd.startinsert()
      if luasnip_ok and luasnip.expandable() then
        luasnip.expand()
      else
        vim.notify('Inserted cpbasic trigger. Press <Tab> to expand snippet.', vim.log.levels.WARN)
      end
    end)

    vim.notify('Created ' .. filepath, vim.log.levels.INFO)
  end)
end

return M
