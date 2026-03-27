return {
  {
    'GCBallesteros/jupytext.nvim',
    enabled = function()
      return vim.fn.executable 'jupytext' == 1
    end,
    opts = {
      style = 'markdown',
      output_extension = 'md',
      force_ft = 'markdown',
    },
    config = function(_, opts)
      local ok_utils, utils = pcall(require, 'jupytext.utils')
      if ok_utils and type(utils.get_ipynb_metadata) == 'function' then
        local extension_by_language = {
          python = 'py',
          julia = 'jl',
          r = 'r',
          R = 'r',
          bash = 'sh',
        }
        local original_get_metadata = utils.get_ipynb_metadata
        utils.get_ipynb_metadata = function(filename)
          local ok_read, raw = pcall(function()
            local file = io.open(filename, 'r')
            if not file then return nil end
            local content = file:read 'a'
            file:close()
            return content
          end)
          if not ok_read or not raw then return { language = 'python', extension = 'py' } end

          local ok_decode, notebook = pcall(vim.json.decode, raw)
          if not ok_decode or type(notebook) ~= 'table' then return { language = 'python', extension = 'py' } end

          local metadata = notebook.metadata or {}
          local kernelspec = metadata.kernelspec or {}
          local language = kernelspec.language
          if not language and kernelspec.name == 'python3' then language = 'python' end
          if not language and type(metadata.language_info) == 'table' then language = metadata.language_info.name end
          if not language then language = 'python' end

          local extension = extension_by_language[language] or 'py'
          return { language = language, extension = extension }
        end

        if opts and opts._debug_restore_jupytext_metadata_reader then utils.get_ipynb_metadata = original_get_metadata end
      end

      require('jupytext').setup(opts)

      local default_notebook = [[
{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
    }
  ],
  "metadata": {
    "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
    },
    "language_info": {
      "name": "python"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
]]

      if vim.fn.exists(':NewNotebook') == 0 then
        vim.api.nvim_create_user_command('NewNotebook', function(command)
          local path = command.args .. '.ipynb'
          local file = io.open(path, 'w')
          if not file then
            vim.notify('Could not create notebook: ' .. path, vim.log.levels.ERROR)
            return
          end
          file:write(default_notebook)
          file:close()
          vim.cmd('edit ' .. vim.fn.fnameescape(path))
        end, {
          nargs = 1,
          complete = 'file',
        })
      end
    end,
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
      return opts
    end,
  },
  {
    'quarto-dev/quarto-nvim',
    ft = { 'quarto', 'markdown' },
    dependencies = {
      'jmbuhr/otter.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      lspFeatures = {
        languages = { 'python' },
        chunks = 'all',
        diagnostics = {
          enabled = true,
          triggers = { 'BufWritePost' },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = 'molten',
      },
    },
    config = function(_, opts)
      require('quarto').setup(opts)
      local group = vim.api.nvim_create_augroup('custom-quarto-maps', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'markdown', 'quarto' },
        group = group,
        callback = function(event)
          local runner = require 'quarto.runner'
          local map_opts = { silent = true, buffer = event.buf }
          vim.keymap.set('n', '<localleader>rc', runner.run_cell, vim.tbl_extend('force', map_opts, { desc = 'run cell' }))
          vim.keymap.set('n', '<localleader>ra', runner.run_above, vim.tbl_extend('force', map_opts, { desc = 'run cell and above' }))
          vim.keymap.set('n', '<localleader>rA', runner.run_all, vim.tbl_extend('force', map_opts, { desc = 'run all cells' }))
          vim.keymap.set('n', '<localleader>rl', runner.run_line, vim.tbl_extend('force', map_opts, { desc = 'run line' }))
          vim.keymap.set('v', '<localleader>r', runner.run_range, vim.tbl_extend('force', map_opts, { desc = 'run visual range' }))
          vim.keymap.set('n', '<localleader>RA', function()
            runner.run_all(true)
          end, vim.tbl_extend('force', map_opts, { desc = 'run all cells of all languages' }))
        end,
      })
    end,
  },
}
