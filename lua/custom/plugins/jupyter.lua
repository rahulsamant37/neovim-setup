---@module 'lazy'
---@type LazySpec
return {
  {
    'goerz/jupytext.nvim',
    version = '0.2.0',
    opts = {
      format = 'markdown',
      autosync = true,
      update = true,
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = function(_, opts)
      opts = opts or {}
      local old_on_attach = opts.on_attach
      opts.on_attach = function(bufnr)
        if vim.api.nvim_buf_get_name(bufnr):match '%.ipynb$' then return false end
        if old_on_attach then return old_on_attach(bufnr) end
      end
    end,
  },
  {
    'benlubas/molten-nvim',
    version = '^1.0.0',
    build = ':UpdateRemotePlugins',
    cmd = {
      'MoltenInit',
      'MoltenInfo',
      'MoltenEvaluateLine',
      'MoltenEvaluateVisual',
      'MoltenReevaluateCell',
      'MoltenDelete',
      'MoltenHideOutput',
      'MoltenEnterOutput',
    },
    init = function()
      vim.g.molten_virt_text_output = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
    end,
    keys = {
      { '<leader>ji', '<cmd>MoltenInit<CR>', desc = 'Jupyter: Init kernel' },
      { '<leader>jl', '<cmd>MoltenEvaluateLine<CR>', desc = 'Jupyter: Run line' },
      { '<leader>jr', '<cmd>MoltenReevaluateCell<CR>', desc = 'Jupyter: Re-run cell' },
      { '<leader>jo', '<cmd>noautocmd MoltenEnterOutput<CR>', desc = 'Jupyter: Open output' },
      { '<leader>jh', '<cmd>MoltenHideOutput<CR>', desc = 'Jupyter: Hide output' },
      { '<leader>jx', '<cmd>MoltenDelete<CR>', desc = 'Jupyter: Clear cell output' },
      { '<leader>jv', ':<C-u>MoltenEvaluateVisual<CR>gv', mode = 'v', desc = 'Jupyter: Run selection' },
    },
  },
}
