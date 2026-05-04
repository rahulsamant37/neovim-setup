-- Minimal test helper for running Lua tests in Neovim headless mode.
-- Usage: require this file, then call assert_* functions.

local M = {}

local passed = 0
local failed = 0
local errors = {}

--- Assert that two values are equal.
---@param actual any
---@param expected any
---@param message? string
function M.assert_eq(actual, expected, message)
  if actual == expected then
    passed = passed + 1
  else
    failed = failed + 1
    local msg = (message or 'assert_eq') .. ': expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual)
    table.insert(errors, msg)
    print('  FAIL: ' .. msg)
  end
end

--- Assert that a value is truthy.
---@param value any
---@param message? string
function M.assert_true(value, message)
  if value then
    passed = passed + 1
  else
    failed = failed + 1
    local msg = (message or 'assert_true') .. ': expected truthy, got ' .. vim.inspect(value)
    table.insert(errors, msg)
    print('  FAIL: ' .. msg)
  end
end

--- Assert that a value is falsy (nil or false).
---@param value any
---@param message? string
function M.assert_false(value, message)
  if not value then
    passed = passed + 1
  else
    failed = failed + 1
    local msg = (message or 'assert_false') .. ': expected falsy, got ' .. vim.inspect(value)
    table.insert(errors, msg)
    print('  FAIL: ' .. msg)
  end
end

--- Assert that a value is nil.
---@param value any
---@param message? string
function M.assert_nil(value, message)
  if value == nil then
    passed = passed + 1
  else
    failed = failed + 1
    local msg = (message or 'assert_nil') .. ': expected nil, got ' .. vim.inspect(value)
    table.insert(errors, msg)
    print('  FAIL: ' .. msg)
  end
end

--- Print test summary and exit with appropriate code.
function M.report()
  print(string.format('\n%d passed, %d failed', passed, failed))
  if failed > 0 then
    os.exit(1)
  end
end

return M
