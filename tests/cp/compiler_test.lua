-- Tests for custom.cp.compiler

-- Add project root to package.path so require() works.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h')
package.path = root .. '/lua/?.lua;' .. root .. '/lua/?/init.lua;' .. package.path

local t = require('tests.test_helper')
local compiler = require('custom.cp.compiler')

print('compiler_test: running...')

-- Test: get_compile_profile_for_source with C++ file
local cpp_profile = compiler.get_compile_profile_for_source('solution.cpp')
t.assert_eq(cpp_profile.compiler, 'g++', 'C++ uses g++')
t.assert_true(cpp_profile.flags:find('c++23', 1, true), 'C++ flags have c++23')
t.assert_true(cpp_profile.label ~= nil, 'C++ profile has label')

-- Test: get_compile_profile_for_source with C file
local c_profile = compiler.get_compile_profile_for_source('solution.c')
t.assert_eq(c_profile.compiler, 'gcc', 'C uses gcc')
t.assert_true(c_profile.flags:find('c17', 1, true), 'C flags have c17')

-- Test: get_compile_profile_for_source with specific mode
local debug_profile = compiler.get_compile_profile_for_source('main.cpp', 'debug')
t.assert_eq(debug_profile.label, 'DEBUG', 'debug mode label')
t.assert_true(debug_profile.flags:find('fsanitize'), 'debug flags have sanitizer')

-- Test: get_stress_compile_profile_for_source for C++
local stress_cpp = compiler.get_stress_compile_profile_for_source('main.cpp')
t.assert_eq(stress_cpp.compiler, 'g++', 'stress C++ uses g++')
t.assert_false(stress_cpp.flags:find('DLOCAL'), 'stress flags have no -DLOCAL')

-- Test: get_stress_compile_profile_for_source for C
local stress_c = compiler.get_stress_compile_profile_for_source('main.c')
t.assert_eq(stress_c.compiler, 'gcc', 'stress C uses gcc')
t.assert_true(stress_c.flags:find('c17', 1, true), 'stress C flags have c17')

t.report()
