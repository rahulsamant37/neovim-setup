-- Compile mode constants, flags, and state management.

local M = {}

--- Clangd LSP command-line arguments.
M.clangd_cmd = {
  'clangd',
  '--background-index',
  '--clang-tidy',
  '--header-insertion=iwyu',
  '--completion-style=detailed',
  '--function-arg-placeholders',
  '--fallback-style={BasedOnStyle: llvm, IndentWidth: 4, TabWidth: 4, UseTab: Never}',
}

--- Compile modes with C++ flags, C flags, and display labels.
M.compile_modes = {
  fast = {
    label = 'FAST',
    flags = '-std=c++23 -O2 -pipe -Wall -Wextra -Wshadow -Wconversion -DLOCAL',
    c_flags = '-std=c17 -O2 -pipe -Wall -Wextra -Wshadow -Wconversion -DLOCAL',
  },
  debug = {
    label = 'DEBUG',
    flags = '-std=c++23 -O0 -g3 -Wall -Wextra -Wshadow -Wconversion -DLOCAL -D_GLIBCXX_DEBUG -fsanitize=address,undefined -fno-omit-frame-pointer',
    c_flags = '-std=c17 -O0 -g3 -Wall -Wextra -Wshadow -Wconversion -DLOCAL -fsanitize=address,undefined -fno-omit-frame-pointer',
  },
  submit = {
    label = 'SUBMIT',
    flags = '-std=c++23 -O2 -pipe -Wall -Wextra -Wshadow -DNDEBUG',
    c_flags = '-std=c17 -O2 -pipe -Wall -Wextra -Wshadow -DNDEBUG',
  },
}

--- Ordered list of mode names (for cycling).
M.compile_mode_order = { 'fast', 'debug', 'submit' }

--- Stress test compile flags (no -DLOCAL, no sanitizers).
M.stress_compile_flags = '-std=c++23 -O2 -pipe -Wall -Wextra -Wshadow'
M.c_stress_compile_flags = '-std=c17 -O2 -pipe -Wall -Wextra -Wshadow'

--- Human-readable list of valid mode names.
M.compile_mode_labels = table.concat(M.compile_mode_order, ', ')

-- Initialize compile mode from vim.g or default to 'fast'.
local compile_mode = vim.g.cp_compile_mode
if not M.compile_modes[compile_mode] then
  compile_mode = 'fast'
end
vim.g.cp_compile_mode = compile_mode

--- Get the current compile mode, or look up a specific mode by name.
---@param mode_name? string
---@return table mode  The mode table (label, flags, c_flags)
---@return string name  The resolved mode name
function M.get_compile_mode(mode_name)
  local name = mode_name or compile_mode
  local mode = M.compile_modes[name]
  if mode then
    return mode, name
  end
  return M.compile_modes.fast, 'fast'
end

--- Set the active compile mode. Updates all loaded C/C++ buffers' makeprg.
---@param mode_name string
---@param silent? boolean
---@return boolean success
function M.set_compile_mode(mode_name, silent)
  if not M.compile_modes[mode_name] then
    vim.notify('Invalid CP mode: ' .. mode_name .. ' (use: ' .. M.compile_mode_labels .. ')', vim.log.levels.ERROR)
    return false
  end

  compile_mode = mode_name
  vim.g.cp_compile_mode = mode_name

  -- Lazy-require compiler to update makeprg on all loaded buffers.
  local compiler = require('custom.cp.compiler')
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      compiler.update_makeprg_for_buffer(bufnr)
    end
  end

  if not silent then
    local mode = M.get_compile_mode()
    vim.notify('CP compile mode: ' .. mode.label, vim.log.levels.INFO)
  end

  return true
end

--- Cycle to the next compile mode in order.
function M.cycle_compile_mode()
  local current_index = 1
  for i, name in ipairs(M.compile_mode_order) do
    if name == compile_mode then
      current_index = i
      break
    end
  end
  local next_index = (current_index % #M.compile_mode_order) + 1
  M.set_compile_mode(M.compile_mode_order[next_index])
end

return M
