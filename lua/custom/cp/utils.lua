-- Shared utility functions for the CP workflow.

local M = {}

--- Check if a source file is C (not C++).
---@param source_file string
---@return boolean
function M.is_c_source(source_file)
  return vim.fn.fnamemodify(source_file, ':e'):lower() == 'c'
end

--- Remove -DLOCAL from compiler flags (for interactive/stress modes).
---@param flags string
---@return string
function M.strip_local_define(flags)
  return flags:gsub('%-DLOCAL%s*', '')
end

--- Ensure a file exists on disk (create empty if missing).
---@param file_path string
function M.ensure_file_exists(file_path)
  if vim.fn.filereadable(file_path) == 0 then
    vim.fn.writefile({}, file_path)
  end
end

--- Copy contents of selected_input into input_file (keeps freopen templates working).
---@param selected_input? string
---@param input_file string
function M.sync_input_file(selected_input, input_file)
  if not selected_input or selected_input == input_file then
    return
  end

  local input_lines = vim.fn.readfile(selected_input)
  vim.fn.writefile(input_lines, input_file)
end

--- Show compiler/runtime output in the quickfix list.
---@param title string
---@param output? string
function M.set_quickfix_from_output(title, output)
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

--- Open a terminal in a vertical split and run a shell script.
---@param script string
function M.open_terminal_script(script)
  vim.cmd.vsplit()
  vim.cmd('terminal sh -c ' .. vim.fn.shellescape(script))
  vim.cmd.startinsert()
end

--- Get context for the current C/C++ buffer (paths, binary location, etc.).
--- Saves the buffer if modified.
---@return table|nil context
function M.get_cpp_context()
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

return M
