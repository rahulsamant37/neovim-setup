-- Tests for custom.cp.config

-- Add project root to package.path so require() works.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h')
package.path = root .. '/lua/?.lua;' .. root .. '/lua/?/init.lua;' .. package.path

local t = require('tests.test_helper')
local config = require('custom.cp.config')

print('config_test: running...')

-- Test: compile_modes has all expected modes
t.assert_true(config.compile_modes.fast, 'fast mode exists')
t.assert_true(config.compile_modes.debug, 'debug mode exists')
t.assert_true(config.compile_modes.submit, 'submit mode exists')

-- Test: each mode has required fields
for _, name in ipairs(config.compile_mode_order) do
  local mode = config.compile_modes[name]
  t.assert_true(mode.label, name .. ' has label')
  t.assert_true(mode.flags, name .. ' has flags')
  t.assert_true(mode.c_flags, name .. ' has c_flags')
end

-- Test: get_compile_mode returns correct mode
local mode, name = config.get_compile_mode('debug')
t.assert_eq(name, 'debug', 'get_compile_mode returns correct name')
t.assert_eq(mode.label, 'DEBUG', 'get_compile_mode returns correct label')

-- Test: get_compile_mode falls back to fast for invalid name
local fallback_mode, fallback_name = config.get_compile_mode('nonexistent')
t.assert_eq(fallback_name, 'fast', 'invalid mode falls back to fast')
t.assert_eq(fallback_mode.label, 'FAST', 'fallback has FAST label')

-- Test: compile_mode_order has 3 entries
t.assert_eq(#config.compile_mode_order, 3, 'compile_mode_order has 3 entries')

-- Test: compile_mode_labels is a comma-separated string
t.assert_eq(config.compile_mode_labels, 'fast, debug, submit', 'compile_mode_labels format')

-- Test: clangd_cmd is a table with clangd as first element
t.assert_eq(config.clangd_cmd[1], 'clangd', 'clangd_cmd starts with clangd')

-- Test: stress compile flags exist
t.assert_true(config.stress_compile_flags:find('c++23', 1, true), 'stress flags have c++23')
t.assert_true(config.c_stress_compile_flags:find('c17', 1, true), 'c stress flags have c17')

t.report()
