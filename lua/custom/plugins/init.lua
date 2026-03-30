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

      vim.keymap.set('n', '<C-_>', api.toggle.linewise.current, { desc = 'Toggle comment' })
      vim.keymap.set('x', '<C-_>', toggle_visual_comment, { desc = 'Toggle comment selection' })

      -- Some terminals send <C-/> and others send <C-_>, so map both.
      vim.keymap.set('n', '<C-/>', api.toggle.linewise.current, { desc = 'Toggle comment' })
      vim.keymap.set('x', '<C-/>', toggle_visual_comment, { desc = 'Toggle comment selection' })
    end,
  },
}
