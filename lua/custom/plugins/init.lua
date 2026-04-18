-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  {
    'tpope/vim-fugitive',
  },
  {
    'numToStr/Comment.nvim',
    opts = {},
    config = function(_, opts)
      require('Comment').setup(opts)

      local api = require 'Comment.api'
      local function toggle_visual_comment()
        local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
        vim.api.nvim_feedkeys(esc, 'nx', false)
        api.toggle.linewise(vim.fn.visualmode())
      end

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc })
      end

      -- Some terminals send <C-/> and others send <C-_>, so map both.
      local toggle_keys = { '<C-_>', '<C-/>' }
      for _, key in ipairs(toggle_keys) do
        map('n', key, api.toggle.linewise.current, 'Toggle comment')
        map('x', key, toggle_visual_comment, 'Toggle comment selection')
      end
    end,
  },
}
