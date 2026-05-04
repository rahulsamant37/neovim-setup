-- Tests for custom.cp.utils

-- Add project root to package.path so require() works.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h')
package.path = root .. '/lua/?.lua;' .. root .. '/lua/?/init.lua;' .. package.path

local t = require('tests.test_helper')
local utils = require('custom.cp.utils')

print('utils_test: running...')

-- Test: is_c_source
t.assert_true(utils.is_c_source('main.c'), 'main.c is C source')
t.assert_true(utils.is_c_source('/path/to/solution.C'), 'solution.C is C source (case-insensitive)')
t.assert_false(utils.is_c_source('main.cpp'), 'main.cpp is not C source')
t.assert_false(utils.is_c_source('main.cc'), 'main.cc is not C source')
t.assert_false(utils.is_c_source('main.lua'), 'main.lua is not C source')

-- Test: strip_local_define
t.assert_eq(
  utils.strip_local_define('-std=c++23 -O2 -DLOCAL -Wall'),
  '-std=c++23 -O2 -Wall',
  'strips -DLOCAL from middle'
)
t.assert_eq(
  utils.strip_local_define('-DLOCAL -std=c++23'),
  '-std=c++23',
  'strips -DLOCAL from start'
)
t.assert_eq(
  utils.strip_local_define('-std=c++23 -Wall'),
  '-std=c++23 -Wall',
  'no -DLOCAL unchanged'
)

-- Test: ensure_file_exists creates file
local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, 'p')
local test_file = tmpdir .. '/test_ensure.txt'
t.assert_eq(vim.fn.filereadable(test_file), 0, 'file does not exist before')
utils.ensure_file_exists(test_file)
t.assert_eq(vim.fn.filereadable(test_file), 1, 'file exists after ensure')

-- Test: ensure_file_exists does not overwrite existing content
vim.fn.writefile({ 'hello' }, test_file)
utils.ensure_file_exists(test_file)
local content = vim.fn.readfile(test_file)
t.assert_eq(content[1], 'hello', 'existing content preserved')

-- Test: sync_input_file copies content
local src_file = tmpdir .. '/src.txt'
local dst_file = tmpdir .. '/dst.txt'
vim.fn.writefile({ 'line1', 'line2' }, src_file)
vim.fn.writefile({}, dst_file)
utils.sync_input_file(src_file, dst_file)
local synced = vim.fn.readfile(dst_file)
t.assert_eq(#synced, 2, 'synced file has 2 lines')
t.assert_eq(synced[1], 'line1', 'synced content matches')

-- Test: sync_input_file skips when same file
utils.sync_input_file(dst_file, dst_file) -- should not error

-- Test: sync_input_file skips when nil
utils.sync_input_file(nil, dst_file) -- should not error

-- Cleanup
vim.fn.delete(tmpdir, 'rf')

t.report()
