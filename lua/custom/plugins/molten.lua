return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    lazy = false,
    build = ':UpdateRemotePlugins',
    init = function()
      -- Linux-safe default: image.nvim may fail when luarocks deps are unavailable.
      vim.g.molten_image_provider = 'none'
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_output_win_max_height = 20
    end,
    config = function()
      local augroup = vim.api.nvim_create_augroup('custom-molten-notebook', { clear = true })

      local function get_available_kernels()
        local ok, kernels = pcall(vim.fn.MoltenAvailableKernels)
        if not ok or type(kernels) ~= 'table' then return {} end
        return kernels
      end

      local function kernel_in_list(kernels, kernel_name)
        if not kernel_name then return false end
        return vim.tbl_contains(kernels, kernel_name)
      end

      vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', { desc = 'evaluate operator', silent = true })
      vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>', { desc = 'initialize molten', silent = true })
      vim.keymap.set('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>', { desc = 'open output window', silent = true })
      vim.keymap.set('n', '<localleader>rr', ':MoltenReevaluateCell<CR>', { desc = 're-eval cell', silent = true })
      vim.keymap.set('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', { desc = 'execute visual selection', silent = true })
      vim.keymap.set('n', '<localleader>oh', ':MoltenHideOutput<CR>', { desc = 'close output window', silent = true })
      vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>', { desc = 'delete Molten cell', silent = true })
      vim.keymap.set('n', '<localleader>mx', ':MoltenOpenInBrowser<CR>', { desc = 'open output in browser', silent = true })

      vim.keymap.set('n', '<localleader>ip', function()
        local kernels = get_available_kernels()
        local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
        if venv ~= nil then
          venv = string.match(venv, '/.+/(.+)')
          if kernel_in_list(kernels, venv) then
            pcall(vim.cmd, ('MoltenInit %s'):format(venv))
            return
          end
        end
        vim.cmd 'MoltenInit'
      end, { desc = 'Initialize Molten for python3', silent = true })

      local init_and_import_ipynb = function(e)
        vim.schedule(function()
          local kernels = get_available_kernels()
          local kernel_name = nil

          local ok_read, lines = pcall(vim.fn.readfile, e.file)
          if ok_read then
            local ok_decode, notebook = pcall(vim.json.decode, table.concat(lines, '\n'))
            if ok_decode and notebook and notebook.metadata and notebook.metadata.kernelspec then
              kernel_name = notebook.metadata.kernelspec.name
            end
          end

          if (not kernel_name) or (not vim.tbl_contains(kernels, kernel_name)) then
            local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
            if venv ~= nil then
              local guessed = string.match(venv, '/.+/(.+)')
              if guessed and vim.tbl_contains(kernels, guessed) then kernel_name = guessed end
            end
          end

          if kernel_name and kernel_in_list(kernels, kernel_name) then
            pcall(vim.cmd, ('MoltenInit %s'):format(kernel_name))
          end

          local ok_status, status = pcall(require, 'molten.status')
          if ok_status and status.initialized() == 'Molten' then pcall(vim.cmd, 'MoltenImportOutput') end
        end)
      end

      vim.api.nvim_create_autocmd('BufAdd', {
        pattern = { '*.ipynb' },
        group = augroup,
        callback = init_and_import_ipynb,
      })

      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = { '*.ipynb' },
        group = augroup,
        callback = function(e)
          if vim.api.nvim_get_vvar 'vim_did_enter' ~= 1 then init_and_import_ipynb(e) end
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { '*.ipynb' },
        group = augroup,
        callback = function()
          local ok_status, status = pcall(require, 'molten.status')
          if ok_status and status.initialized() == 'Molten' then vim.cmd 'MoltenExportOutput!' end
        end,
      })
    end,
  },
}
