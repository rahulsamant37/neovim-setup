-- Test file discovery, creation, comparison, and cleanup.

local utils = require('custom.cp.utils')

local M = {}

--- Get sorted list of numbered test case indices from a directory.
--- Scans for files matching inputN.txt.
---@param source_dir string
---@return integer[]
function M.get_numbered_test_cases(source_dir)
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

--- Find the first readable numbered file with a given prefix (input/output).
---@param source_dir string
---@param prefix string  e.g. 'input' or 'output'
---@param cases integer[]  sorted case indices
---@param legacy_name string  fallback filename (e.g. 'input.txt' or 'expected.txt')
---@return string|nil
local function get_first_numbered_file(source_dir, prefix, cases, legacy_name)
  for _, idx in ipairs(cases) do
    local candidate = source_dir .. '/' .. prefix .. idx .. '.txt'
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  local legacy_path = source_dir .. '/' .. legacy_name
  if vim.fn.filereadable(legacy_path) == 1 then
    return legacy_path
  end

  return nil
end

--- Get the primary input file for a source directory.
---@param source_dir string
---@return string|nil
function M.get_primary_input_file(source_dir)
  local cases = M.get_numbered_test_cases(source_dir)
  return get_first_numbered_file(source_dir, 'input', cases, 'input.txt')
end

--- Get the expected output file for a source directory.
---@param source_dir string
---@return string|nil
function M.get_expected_output_file(source_dir)
  local cases = M.get_numbered_test_cases(source_dir)
  return get_first_numbered_file(source_dir, 'output', cases, 'expected.txt')
end

--- Create or open test files (input1.txt + output1.txt) in splits.
function M.create_test_files()
  local ctx = utils.get_cpp_context()
  if not ctx then
    return
  end

  local original_win = vim.api.nvim_get_current_win()
  local numbered_cases = M.get_numbered_test_cases(ctx.source_dir)

  local case_id = 1
  if #numbered_cases > 0 then
    case_id = numbered_cases[1]
  end

  local input_file = ctx.source_dir .. '/input' .. case_id .. '.txt'
  local expected_file = ctx.source_dir .. '/output' .. case_id .. '.txt'

  utils.ensure_file_exists(input_file)
  utils.ensure_file_exists(expected_file)

  vim.cmd('split ' .. vim.fn.fnameescape(input_file))
  vim.cmd('vsplit ' .. vim.fn.fnameescape(expected_file))

  if vim.api.nvim_win_is_valid(original_win) then
    vim.api.nvim_set_current_win(original_win)
  end

  vim.notify(string.format('Test files ready (input%d.txt + output%d.txt)!', case_id, case_id), vim.log.levels.INFO)
end

--- Compare output.txt with expected output in a diff view.
function M.compare_output()
  local ctx = utils.get_cpp_context()
  if not ctx then
    return
  end

  local expected_file = M.get_expected_output_file(ctx.source_dir)

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

--- Delete generated CP artifacts (test files, binaries) while preserving source.
function M.clear_test_residue()
  local ctx = utils.get_cpp_context()
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

return M
