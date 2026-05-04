-- Tests for custom.cp.testcase

-- Add project root to package.path so require() works.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h')
package.path = root .. '/lua/?.lua;' .. root .. '/lua/?/init.lua;' .. package.path

local t = require('tests.test_helper')
local testcase = require('custom.cp.testcase')

print('testcase_test: running...')

-- Create a temp directory with numbered test files
local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, 'p')

-- Test: get_numbered_test_cases with no files
local empty_cases = testcase.get_numbered_test_cases(tmpdir)
t.assert_eq(#empty_cases, 0, 'no test cases in empty dir')

-- Create some numbered input files
vim.fn.writefile({ '1 2' }, tmpdir .. '/input1.txt')
vim.fn.writefile({ '3 4' }, tmpdir .. '/input3.txt')
vim.fn.writefile({ '5 6' }, tmpdir .. '/input2.txt')
-- Also create a non-matching file
vim.fn.writefile({}, tmpdir .. '/input.txt')

-- Test: get_numbered_test_cases finds and sorts correctly
local cases = testcase.get_numbered_test_cases(tmpdir)
t.assert_eq(#cases, 3, 'found 3 numbered cases')
t.assert_eq(cases[1], 1, 'first case is 1')
t.assert_eq(cases[2], 2, 'second case is 2')
t.assert_eq(cases[3], 3, 'third case is 3')

-- Test: get_primary_input_file returns first numbered file
local primary = testcase.get_primary_input_file(tmpdir)
t.assert_eq(primary, tmpdir .. '/input1.txt', 'primary input is input1.txt')

-- Test: get_primary_input_file falls back to input.txt
local tmpdir2 = vim.fn.tempname()
vim.fn.mkdir(tmpdir2, 'p')
vim.fn.writefile({ 'legacy' }, tmpdir2 .. '/input.txt')
local legacy = testcase.get_primary_input_file(tmpdir2)
t.assert_eq(legacy, tmpdir2 .. '/input.txt', 'falls back to input.txt')

-- Test: get_primary_input_file returns nil when nothing exists
local tmpdir3 = vim.fn.tempname()
vim.fn.mkdir(tmpdir3, 'p')
local nothing = testcase.get_primary_input_file(tmpdir3)
t.assert_nil(nothing, 'nil when no input files')

-- Test: get_expected_output_file returns first numbered output
vim.fn.writefile({ 'out1' }, tmpdir .. '/output1.txt')
local expected = testcase.get_expected_output_file(tmpdir)
t.assert_eq(expected, tmpdir .. '/output1.txt', 'expected output is output1.txt')

-- Test: get_expected_output_file falls back to expected.txt
local tmpdir4 = vim.fn.tempname()
vim.fn.mkdir(tmpdir4, 'p')
vim.fn.writefile({ 'exp' }, tmpdir4 .. '/expected.txt')
local legacy_exp = testcase.get_expected_output_file(tmpdir4)
t.assert_eq(legacy_exp, tmpdir4 .. '/expected.txt', 'falls back to expected.txt')

-- Cleanup
vim.fn.delete(tmpdir, 'rf')
vim.fn.delete(tmpdir2, 'rf')
vim.fn.delete(tmpdir3, 'rf')
vim.fn.delete(tmpdir4, 'rf')

t.report()
