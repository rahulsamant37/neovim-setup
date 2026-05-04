-- CP-Algorithms document shortcuts.

local M = {}

--- Get the cp-algorithms source directory.
---@return string
function M.cpalg_src_dir()
  return vim.env.CPALG_SRC or (vim.env.HOME .. '/github/cp-algorithms/src')
end

--- Document paths relative to cpalg_src_dir.
M.docs = {
  roadmap = 'essential_learning_path.md',
  weekly_plan = 'essential_weekly_plan.md',
  read_list = 'essential_read_first_order.txt',
  revise_list = 'essential_revise_later_order.txt',
}

--- Open a file from the cp-algorithms source directory.
---@param relative_path string
function M.open_cpalg_file(relative_path)
  local path = M.cpalg_src_dir() .. '/' .. relative_path

  if vim.fn.filereadable(path) == 0 then
    vim.notify('CP-Algorithms file not found: ' .. path, vim.log.levels.WARN)
    return
  end

  vim.cmd.edit(vim.fn.fnameescape(path))
end

--- Return a closure that opens a specific cp-algorithms file.
---@param relative_path string
---@return function
function M.open_cpalg(relative_path)
  return function()
    M.open_cpalg_file(relative_path)
  end
end

return M
