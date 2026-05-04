-- Compile profile selection and compilation logic.

local config = require('custom.cp.config')
local utils = require('custom.cp.utils')

local M = {}

--- Get compile profile (compiler, flags, label) for a source file.
---@param source_file string
---@param mode_name? string
---@return table profile  { compiler, flags, label }
function M.get_compile_profile_for_source(source_file, mode_name)
  local mode, selected_mode = config.get_compile_mode(mode_name)

  if utils.is_c_source(source_file) then
    return {
      compiler = 'gcc',
      flags = mode.c_flags,
      label = mode.label,
    }
  end

  return {
    compiler = 'g++',
    flags = mode.flags,
    label = mode.label,
  }
end

--- Get stress-test compile profile for a source file (optimized, no -DLOCAL).
---@param source_file string
---@return table profile  { compiler, flags }
function M.get_stress_compile_profile_for_source(source_file)
  if utils.is_c_source(source_file) then
    return {
      compiler = 'gcc',
      flags = config.c_stress_compile_flags,
    }
  end

  return {
    compiler = 'g++',
    flags = config.stress_compile_flags,
  }
end

--- Get compile profile for a buffer (falls back to filetype if file unnamed).
---@param bufnr integer
---@param mode_name? string
---@return table profile  { compiler, flags, label }
function M.get_compile_profile_for_buffer(bufnr, mode_name)
  local source_file = vim.api.nvim_buf_get_name(bufnr)
  if source_file ~= '' then
    return M.get_compile_profile_for_source(source_file, mode_name)
  end

  -- Unnamed buffer: use filetype to decide compiler.
  local mode, _ = config.get_compile_mode(mode_name)
  local ft = vim.bo[bufnr].filetype
  if ft == 'c' then
    return {
      compiler = 'gcc',
      flags = mode.c_flags,
      label = mode.label,
    }
  end

  return {
    compiler = 'g++',
    flags = mode.flags,
    label = mode.label,
  }
end

--- Update makeprg for a C/C++ buffer based on the current compile mode.
---@param bufnr integer
function M.update_makeprg_for_buffer(bufnr)
  local ft = vim.bo[bufnr].filetype
  if ft ~= 'c' and ft ~= 'cpp' then
    return
  end

  local profile = M.get_compile_profile_for_buffer(bufnr)
  vim.bo[bufnr].makeprg = string.format('%s %s %% -o %%:r', profile.compiler, profile.flags)
end

--- Compile a source file to a binary. Shows errors in quickfix on failure.
---@param source_file string
---@param binary_path string
---@param compiler string
---@param flags string
---@param quickfix_title string
---@return boolean success
function M.compile_source_file(source_file, binary_path, compiler, flags, quickfix_title)
  local compile_cmd = string.format(
    '%s %s %s -o %s 2>&1',
    compiler,
    flags,
    vim.fn.shellescape(source_file),
    vim.fn.shellescape(binary_path)
  )

  local output = vim.fn.system(compile_cmd)
  if vim.v.shell_error ~= 0 then
    utils.set_quickfix_from_output(quickfix_title, output)
    return false
  end

  vim.cmd.cclose()
  return true
end

--- Compile the current buffer's source file. Optionally notify on success.
---@param notify_success boolean
---@return boolean ok
---@return table|nil context
function M.compile_cpp_with_result(notify_success)
  local ctx = utils.get_cpp_context()
  if not ctx then
    return false, nil
  end

  local profile = M.get_compile_profile_for_buffer(ctx.bufnr)
  local ok = M.compile_source_file(ctx.source_file, ctx.binary_path, profile.compiler, profile.flags, 'Compilation Errors')

  if ok then
    if notify_success then
      vim.notify('Compilation successful [' .. profile.label .. ']!', vim.log.levels.INFO)
    end
  else
    vim.notify('Compilation failed!', vim.log.levels.ERROR)
  end

  return ok, ctx
end

return M
