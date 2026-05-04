-- Competitive Programming Plugin Configuration
-- Keybindings, user commands, autocmds, and LSP setup.
-- All core logic lives in custom.cp.* submodules.

local config = require('custom.cp.config')
local compiler = require('custom.cp.compiler')
local runner = require('custom.cp.runner')
local testcase = require('custom.cp.testcase')
local stress = require('custom.cp.stress')
local cpalg = require('custom.cp.cpalg')
local utils = require('custom.cp.utils')

-- ==================== CLANGD LSP ====================

local function configure_clangd()
  if vim.fn.executable('clangd') ~= 1 then
    return
  end

  vim.lsp.config('clangd', {
    cmd = config.clangd_cmd,
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  })

  vim.lsp.enable('clangd')
end

configure_clangd()

-- ==================== CP-SPECIFIC OPTIONS ====================

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('cp-filetype-options', { clear = true }),
  pattern = { 'cpp', 'c' },
  callback = function()
    compiler.update_makeprg_for_buffer(0)

    -- Set tab width to 4 for C/C++ (common in CP)
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- ==================== KEYBINDINGS ====================

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('cp-filetype-keymaps', { clear = true }),
  pattern = { 'cpp', 'c' },
  callback = function()
    local opts = { buffer = true, silent = true }
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', opts, { desc = desc }))
    end

    -- Compile and run
    map('n', '<F5>', runner.compile_and_run, 'Compile and Run')
    map('n', '<leader>cr', runner.compile_and_run, '[C]ompile and [R]un')

    -- Compile only
    map('n', '<F9>', runner.compile_only, 'Compile Only')
    map('n', '<leader>cc', runner.compile_only, '[C]ompile [C]heck')

    -- Run with custom input
    map('n', '<F6>', runner.run_with_input, 'Run with Input')
    map('n', '<leader>ci', runner.run_with_input, '[C]ustom [I]nput')
    map('n', '<leader>r', runner.run_interactive, 'Run interactively (:CPRunInteractive)')
    map('n', '<F7>', runner.run_interactive, 'Run interactively (:CPRunInteractive)')

    -- Test file management
    map('n', '<leader>t', testcase.create_test_files, '[T]est files')
    map('n', '<leader>ct', testcase.create_test_files, '[C]reate [T]est files')
    map('n', '<leader>cd', testcase.compare_output, '[C]ompare [D]iff')
    map('n', '<leader>x', testcase.clear_test_residue, 'Delete CP artifacts (input*/output*/expected* + exe)')

    -- New CP file and stress test
    map('n', '<leader>cn', runner.new_cp_file, '[C]reate [N]ew CP file')
    map('n', '<leader>cs', stress.stress_test, '[C]P [S]tress test')

    -- Compile mode controls
    map('n', '<leader>cm', config.cycle_compile_mode, '[C]ycle compile [M]ode')
    map('n', '<leader>cM', function()
      vim.ui.select(config.compile_mode_order, { prompt = 'Select CP compile mode:' }, function(choice)
        if choice then
          config.set_compile_mode(choice)
        end
      end)
    end, 'Pick compile mode')

    -- Quick snippet trigger in insert mode
    map('i', '<C-s>', function()
      local ok, luasnip = pcall(require, 'luasnip')
      if ok and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, 'Expand/jump snippet')
  end,
})

-- Global keybindings
vim.keymap.set('n', '<leader>cp', ':edit ~/.config/nvim/lua/custom/plugins/cp.lua<CR>', { desc = 'Edit [C][P] config' })

local cpalg_keymap_specs = {
  { '<leader>ar', cpalg.docs.roadmap, '[A]lgorithms [R]oadmap' },
  { '<leader>aw', cpalg.docs.weekly_plan, '[A]lgorithms [W]eekly plan' },
  { '<leader>al', cpalg.docs.read_list, '[A]lgorithms [L]ist (read first)' },
  { '<leader>aL', cpalg.docs.revise_list, '[A]lgorithms revise [L]ist' },
}

for _, keymap in ipairs(cpalg_keymap_specs) do
  vim.keymap.set('n', keymap[1], cpalg.open_cpalg(keymap[2]), { desc = keymap[3] })
end

-- ==================== COMMANDS ====================

local cp_command_specs = {
  { 'CPRun', runner.compile_and_run, 'Compile and run C/C++ file' },
  { 'CPRunInteractive', runner.run_interactive, 'Run compiled binary interactively (prompt for input; does NOT auto-use input1.txt)' },
  { 'CPCompile', runner.compile_only, 'Compile C/C++ file' },
  { 'CPTest', testcase.create_test_files, 'Create/open test files' },
  { 'CPDiff', testcase.compare_output, 'Compare output.txt with expected output' },
  { 'CPClear', testcase.clear_test_residue, 'Delete CP artifacts (input*/output*/expected* + executable)' },
  { 'CPNew', runner.new_cp_file, 'Create new C/C++ CP file from template' },
}

for _, cmd in ipairs(cp_command_specs) do
  vim.api.nvim_create_user_command(cmd[1], cmd[2], { desc = cmd[3] })
end

vim.api.nvim_create_user_command('CPStress', stress.stress_test, {
  desc = 'Stress test: :CPStress [generator.c/cpp] [brute.c/cpp] [iterations]',
  nargs = '*',
})

vim.api.nvim_create_user_command('CPMode', function(opts)
  config.set_compile_mode(vim.trim(opts.args))
end, {
  desc = 'Set compile mode: fast|debug|submit',
  nargs = 1,
  complete = function()
    return config.compile_mode_order
  end,
})

vim.api.nvim_create_user_command('CPCycleMode', config.cycle_compile_mode, { desc = 'Cycle compile mode' })

local cpalg_command_specs = {
  { 'CPARoadmap', cpalg.docs.roadmap, 'Open CP-Algorithms essential roadmap' },
  { 'CPAWeeklyPlan', cpalg.docs.weekly_plan, 'Open CP-Algorithms weekly plan' },
  { 'CPAReadList', cpalg.docs.read_list, 'Open CP-Algorithms read-first list' },
  { 'CPAReviseList', cpalg.docs.revise_list, 'Open CP-Algorithms revise-later list' },
}

for _, cmd in ipairs(cpalg_command_specs) do
  vim.api.nvim_create_user_command(cmd[1], cpalg.open_cpalg(cmd[2]), { desc = cmd[3] })
end

-- ==================== AUTO-COMMANDS ====================

-- Auto-create input1.txt/output1.txt when opening a new C/C++ file.
vim.api.nvim_create_autocmd('BufNewFile', {
  group = vim.api.nvim_create_augroup('cp-new-c-files', { clear = true }),
  pattern = { '*.cpp', '*.cc', '*.cxx', '*.c' },
  callback = function()
    local source_dir = vim.fn.expand('%:p:h')
    local input_file = source_dir .. '/input1.txt'
    local expected_file = source_dir .. '/output1.txt'

    utils.ensure_file_exists(input_file)
    utils.ensure_file_exists(expected_file)
  end,
})

-- Apply initial compile mode to all buffers.
config.set_compile_mode(vim.g.cp_compile_mode or 'fast', true)

-- Cache the module so require('custom.plugins.cp') returns the public API.
package.loaded['custom.plugins.cp'] = require('custom.cp')

-- Return empty spec for lazy.nvim (no external plugin dependency).
return {}
