-- autopairs
-- https://github.com/windwp/nvim-autopairs

---@module 'lazy'
---@type LazySpec
return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    disable_filetype = { 'TelescopePrompt', 'spectre_panel', 'snacks_picker_input' },
  },
  config = function(_, opts)
    local npairs = require 'nvim-autopairs'
    local Rule = require 'nvim-autopairs.rule'

    npairs.setup(opts)

    -- Keep core pairing behavior consistent across these languages.
    local c_like_filetypes = { 'c', 'cpp', 'rust', 'java' }
    local c_like_pairs = {
      { '(', ')' },
      { '[', ']' },
      { '{', '}' },
      { '"', '"' },
      { "'", "'" },
    }

    local rules = {}
    for _, pair in ipairs(c_like_pairs) do
      table.insert(rules, Rule(pair[1], pair[2], c_like_filetypes))
    end

    npairs.add_rules(rules)
  end,
}
