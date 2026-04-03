-- Competitive Programming Setup for Neovim
-- This file contains CP-specific configurations and keybindings

return {
  -- clangd LSP for C++ (already configured in main init.lua, just enabling it)
  {
    'neovim/nvim-lspconfig',
    opts = function()
      -- Enable clangd if available
      if vim.fn.executable('clangd') == 1 then
        vim.lsp.config('clangd', {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        })
        vim.lsp.enable('clangd')
      end
    end,
  },

  -- Enhanced C++ syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function()
      -- Ensure C++ parser is installed
      vim.cmd('TSInstall cpp')
    end,
  },
}
