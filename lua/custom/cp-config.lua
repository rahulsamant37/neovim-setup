-- Competitive Programming Configuration
-- Keybindings and utilities for fast CP workflow

local M = {}

-- ==================== CP-SPECIFIC OPTIONS ====================
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cpp', 'c' },
  callback = function()
    -- Fast compilation settings
    vim.opt_local.makeprg = 'g++ -std=c++23 -O2 -Wall -Wextra -Wshadow -DLOCAL % -o %:r'
    
    -- Set tab width to 4 for C++ (common in CP)
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- ==================== QUICK COMPILE & RUN ====================
-- Enhanced version with better error handling and timing

local function compile_and_run_cpp()
  local bufnr = vim.api.nvim_get_current_buf()
  local source_file = vim.api.nvim_buf_get_name(bufnr)
  
  if source_file == '' then
    vim.notify('Save the file first!', vim.log.levels.WARN)
    return
  end

  -- Auto-save
  if vim.bo[bufnr].modified then
    vim.cmd.write()
  end

  source_file = vim.fn.fnamemodify(source_file, ':p')
  local source_dir = vim.fn.fnamemodify(source_file, ':h')
  local source_base = vim.fn.fnamemodify(source_file, ':t:r')
  local binary_path = source_dir .. '/' .. source_base
  local input_file = source_dir .. '/input.txt'
  local output_file = source_dir .. '/output.txt'
  local expected_file = source_dir .. '/expected.txt'

  -- Compile with LOCAL flag for debugging
  local compile_cmd = string.format(
    'g++ -std=c++23 -O2 -Wall -Wextra -Wshadow -DLOCAL -g %s -o %s 2>&1',
    vim.fn.shellescape(source_file),
    vim.fn.shellescape(binary_path)
  )

  vim.notify('Compiling...', vim.log.levels.INFO)
  local compile_output = vim.fn.system(compile_cmd)
  local compile_exit = vim.v.shell_error

  if compile_exit ~= 0 then
    -- Parse errors and show in quickfix
    vim.fn.setqflist({}, 'r', {
      title = 'Compilation Errors',
      lines = vim.split(compile_output, '\n'),
    })
    vim.cmd.copen()
    vim.notify('Compilation failed!', vim.log.levels.ERROR)
    return
  end

  vim.cmd.cclose()
  vim.notify('Compilation successful!', vim.log.levels.INFO)

  -- Run with input.txt if it exists
  local run_cmd = vim.fn.shellescape(binary_path)
  if vim.fn.filereadable(input_file) == 1 then
    run_cmd = run_cmd .. ' < ' .. vim.fn.shellescape(input_file)
    if vim.fn.filereadable(output_file) == 1 then
      run_cmd = run_cmd .. ' > ' .. vim.fn.shellescape(output_file)
    end
  end

  -- Add timing
  run_cmd = 'time ' .. run_cmd

  -- Open in split terminal
  vim.cmd.vsplit()
  vim.cmd('terminal ' .. run_cmd)
  vim.cmd.startinsert()
end

-- Compile only (for checking errors)
local function compile_cpp()
  local bufnr = vim.api.nvim_get_current_buf()
  local source_file = vim.api.nvim_buf_get_name(bufnr)
  
  if source_file == '' then
    vim.notify('Save the file first!', vim.log.levels.WARN)
    return
  end

  if vim.bo[bufnr].modified then
    vim.cmd.write()
  end

  source_file = vim.fn.fnamemodify(source_file, ':p')
  local source_dir = vim.fn.fnamemodify(source_file, ':h')
  local source_base = vim.fn.fnamemodify(source_file, ':t:r')
  local binary_path = source_dir .. '/' .. source_base

  local compile_cmd = string.format(
    'g++ -std=c++23 -O2 -Wall -Wextra -Wshadow -DLOCAL -g %s -o %s 2>&1',
    vim.fn.shellescape(source_file),
    vim.fn.shellescape(binary_path)
  )

  vim.notify('Compiling...', vim.log.levels.INFO)
  local compile_output = vim.fn.system(compile_cmd)
  local compile_exit = vim.v.shell_error

  if compile_exit ~= 0 then
    vim.fn.setqflist({}, 'r', {
      title = 'Compilation Errors',
      lines = vim.split(compile_output, '\n'),
    })
    vim.cmd.copen()
    vim.notify('Compilation failed!', vim.log.levels.ERROR)
  else
    vim.cmd.cclose()
    vim.notify('Compilation successful!', vim.log.levels.INFO)
  end
end

-- Run with custom input
local function run_with_input()
  local bufnr = vim.api.nvim_get_current_buf()
  local source_file = vim.api.nvim_buf_get_name(bufnr)
  local source_dir = vim.fn.fnamemodify(source_file, ':h')
  local source_base = vim.fn.fnamemodify(source_file, ':t:r')
  local binary_path = source_dir .. '/' .. source_base

  if vim.fn.filereadable(binary_path) == 0 then
    vim.notify('Binary not found! Compile first.', vim.log.levels.ERROR)
    return
  end

  -- Prompt for input
  vim.ui.input({ prompt = 'Enter input (or file path): ' }, function(input)
    if not input then return end
    
    local run_cmd
    if vim.fn.filereadable(input) == 1 then
      run_cmd = vim.fn.shellescape(binary_path) .. ' < ' .. vim.fn.shellescape(input)
    else
      run_cmd = 'echo ' .. vim.fn.shellescape(input) .. ' | ' .. vim.fn.shellescape(binary_path)
    end

    vim.cmd.vsplit()
    vim.cmd('terminal ' .. run_cmd)
    vim.cmd.startinsert()
  end)
end

-- Create test files (input.txt, output.txt, expected.txt)
local function create_test_files()
  local source_file = vim.api.nvim_buf_get_name(0)
  local source_dir = vim.fn.fnamemodify(source_file, ':h')
  
  local input_file = source_dir .. '/input.txt'
  local output_file = source_dir .. '/output.txt'
  local expected_file = source_dir .. '/expected.txt'

  -- Create files if they don't exist
  if vim.fn.filereadable(input_file) == 0 then
    vim.fn.writefile({}, input_file)
  end
  if vim.fn.filereadable(output_file) == 0 then
    vim.fn.writefile({}, output_file)
  end
  if vim.fn.filereadable(expected_file) == 0 then
    vim.fn.writefile({}, expected_file)
  end

  -- Open in splits
  vim.cmd('split ' .. input_file)
  vim.cmd('vsplit ' .. expected_file)
  vim.cmd.wincmd('h')
  
  vim.notify('Test files created/opened!', vim.log.levels.INFO)
end

-- Compare output with expected
local function compare_output()
  local source_file = vim.api.nvim_buf_get_name(0)
  local source_dir = vim.fn.fnamemodify(source_file, ':h')
  local output_file = source_dir .. '/output.txt'
  local expected_file = source_dir .. '/expected.txt'

  if vim.fn.filereadable(output_file) == 0 then
    vim.notify('output.txt not found!', vim.log.levels.ERROR)
    return
  end
  if vim.fn.filereadable(expected_file) == 0 then
    vim.notify('expected.txt not found!', vim.log.levels.ERROR)
    return
  end

  vim.cmd('tabnew')
  vim.cmd('edit ' .. output_file)
  vim.cmd('vsplit ' .. expected_file)
  vim.cmd.windo('diffthis')
  
  vim.notify('Comparing output with expected...', vim.log.levels.INFO)
end

-- Create new CP file from template
local function new_cp_file()
  vim.ui.input({ prompt = 'Enter filename (without .cpp): ' }, function(filename)
    if not filename then return end
    
    local filepath = filename .. '.cpp'
    vim.cmd('edit ' .. filepath)
    
    -- Insert basic template trigger
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { 'cpbasic' })
    
    -- Trigger snippet expansion
    vim.cmd('normal! A')
    vim.cmd('startinsert!')
    
    vim.notify('Created ' .. filepath, vim.log.levels.INFO)
  end)
end

-- Stress testing function
local function stress_test()
  vim.notify('Stress testing not yet implemented. Use external tools like cf-tool or oj.', vim.log.levels.WARN)
end

-- ==================== KEYBINDINGS ====================
-- These are CP-specific keybindings for fast workflow

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cpp', 'c' },
  callback = function()
    local opts = { buffer = true, silent = true }
    
    -- Compile and run
    vim.keymap.set('n', '<F5>', compile_and_run_cpp, vim.tbl_extend('force', opts, { desc = 'Compile and Run' }))
    vim.keymap.set('n', '<leader>cr', compile_and_run_cpp, vim.tbl_extend('force', opts, { desc = '[C]ompile and [R]un' }))
    
    -- Compile only
    vim.keymap.set('n', '<F9>', compile_cpp, vim.tbl_extend('force', opts, { desc = 'Compile Only' }))
    vim.keymap.set('n', '<leader>cc', compile_cpp, vim.tbl_extend('force', opts, { desc = '[C]ompile [C]heck' }))
    
    -- Run with custom input
    vim.keymap.set('n', '<F6>', run_with_input, vim.tbl_extend('force', opts, { desc = 'Run with Input' }))
    vim.keymap.set('n', '<leader>ci', run_with_input, vim.tbl_extend('force', opts, { desc = '[C]ustom [I]nput' }))
    
    -- Test file management
    vim.keymap.set('n', '<leader>ct', create_test_files, vim.tbl_extend('force', opts, { desc = '[C]reate [T]est files' }))
    vim.keymap.set('n', '<leader>cd', compare_output, vim.tbl_extend('force', opts, { desc = '[C]ompare [D]iff' }))
    
    -- New CP file
    vim.keymap.set('n', '<leader>cn', new_cp_file, vim.tbl_extend('force', opts, { desc = '[C]reate [N]ew CP file' }))
    
    -- Quick snippet triggers (in insert mode)
    vim.keymap.set('i', '<C-s>', '<Esc>:lua require("luasnip").expand_or_jump()<CR>', opts)
  end,
})

-- Global keybindings (available in all modes)
vim.keymap.set('n', '<leader>cp', ':edit ~/.config/nvim/lua/custom/cp-config.lua<CR>', { desc = 'Edit [C][P] config' })

-- ==================== COMMANDS ====================
vim.api.nvim_create_user_command('CPRun', compile_and_run_cpp, { desc = 'Compile and run C++ file' })
vim.api.nvim_create_user_command('CPCompile', compile_cpp, { desc = 'Compile C++ file' })
vim.api.nvim_create_user_command('CPTest', create_test_files, { desc = 'Create/open test files' })
vim.api.nvim_create_user_command('CPDiff', compare_output, { desc = 'Compare output with expected' })
vim.api.nvim_create_user_command('CPNew', new_cp_file, { desc = 'Create new CP file from template' })

-- ==================== AUTO-COMMANDS ====================
-- Auto-create input.txt when opening a .cpp file
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.cpp',
  callback = function()
    local source_dir = vim.fn.expand('%:p:h')
    local input_file = source_dir .. '/input.txt'
    
    if vim.fn.filereadable(input_file) == 0 then
      vim.fn.writefile({}, input_file)
    end
  end,
})

M.compile_and_run = compile_and_run_cpp
M.compile_only = compile_cpp
M.create_test_files = create_test_files
M.compare_output = compare_output
M.new_cp_file = new_cp_file

return M
