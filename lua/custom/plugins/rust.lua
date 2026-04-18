-- Rust development setup.

local function configure_rust_analyzer()
  if vim.fn.executable 'rust-analyzer' ~= 1 then
    return
  end

  local check_command = vim.fn.executable 'cargo-clippy' == 1 and 'clippy' or 'check'

  vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        check = {
          command = check_command,
        },
        procMacro = {
          enable = true,
        },
        diagnostics = {
          enable = true,
        },
        completion = {
          autoimport = { enable = true },
        },
      },
    },
  })

  vim.lsp.enable 'rust_analyzer'
end

local function set_crates_keymaps(bufnr, crates)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, {
      buffer = bufnr,
      silent = true,
      desc = desc,
    })
  end

  local mappings = {
    { 'n', '<leader>cv', crates.show_versions_popup, 'Crates: Show versions' },
    { 'n', '<leader>cf', crates.show_features_popup, 'Crates: Show features' },
    { 'n', '<leader>cd', crates.show_dependencies_popup, 'Crates: Show dependencies' },
    { 'n', '<leader>cu', crates.update_crate, 'Crates: Update crate' },
    { 'v', '<leader>cu', crates.update_crates, 'Crates: Update selected crates' },
    { 'n', '<leader>ca', crates.update_all_crates, 'Crates: Update all crates' },
    { 'n', '<leader>cU', crates.upgrade_crate, 'Crates: Upgrade crate' },
    { 'v', '<leader>cU', crates.upgrade_crates, 'Crates: Upgrade selected crates' },
    { 'n', '<leader>cA', crates.upgrade_all_crates, 'Crates: Upgrade all crates' },
  }

  for _, mapping in ipairs(mappings) do
    map(mapping[1], mapping[2], mapping[3], mapping[4])
  end
end

---@module 'lazy'
---@type LazySpec
return {
  {
    'neovim/nvim-lspconfig',
    opts = function()
      configure_rust_analyzer()
    end,
  },
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml', 'BufNewFile Cargo.toml' },
    tag = 'stable',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      popup = {
        autofocus = true,
        border = 'rounded',
      },
    },
    config = function(_, opts)
      local crates = require 'crates'
      crates.setup(opts)

      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('cargo-crates-keymaps', { clear = true }),
        pattern = 'Cargo.toml',
        callback = function(event)
          if vim.b[event.buf].cargo_crates_keymaps_set then
            return
          end
          vim.b[event.buf].cargo_crates_keymaps_set = true

          set_crates_keymaps(event.buf, crates)
        end,
      })
    end,
  },
}