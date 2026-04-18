local M = {}

local function quickref_dir()
  return vim.env.QUICKREF_DIR or (vim.env.HOME .. '/github/quickref')
end

local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.notify('Quickref directory not found: ' .. path, vim.log.levels.WARN)
    return false
  end
  return true
end

local function telescope_builtin()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if not ok then
    vim.notify('Telescope is not available in this Neovim session.', vim.log.levels.ERROR)
    return nil
  end
  return builtin
end

local function make_slug(raw)
  local slug = raw:lower():gsub('[^a-z0-9]+', '-'):gsub('^-+', ''):gsub('-+$', '')
  if slug == '' then
    slug = 'note'
  end
  return slug
end

local function new_note(path, title)
  local trimmed = (title or ''):gsub('^%s+', ''):gsub('%s+$', '')
  if trimmed == '' then
    trimmed = 'Quick Note'
  end

  local year = os.date '%Y'
  local month = os.date '%m'
  local day = os.date '%Y-%m-%d'

  local folder = string.format('%s/notes/%s/%s', path, year, month)
  vim.fn.mkdir(folder, 'p')

  local filename = string.format('%s-%s.md', day, make_slug(trimmed))
  local fullpath = folder .. '/' .. filename

  if vim.fn.filereadable(fullpath) == 0 then
    local lines = {
      '# ' .. trimmed,
      '',
      'Created: ' .. day,
      '',
      '## Summary',
      '',
      '## Details',
      '',
      '## Commands',
      '',
      '## Links',
      '',
    }
    vim.fn.writefile(lines, fullpath)
  end

  vim.cmd.edit(vim.fn.fnameescape(fullpath))
end

local function run_telescope_picker(path, picker, opts)
  if not ensure_dir(path) then
    return
  end

  local builtin = telescope_builtin()
  if not builtin then
    return
  end

  local picker_fn = builtin[picker]
  if type(picker_fn) ~= 'function' then
    vim.notify('Telescope picker not available: ' .. picker, vim.log.levels.ERROR)
    return
  end

  picker_fn(opts)
end

function M.setup()
  local path = quickref_dir()

  local function create_command(name, rhs, opts)
    vim.api.nvim_create_user_command(name, rhs, opts)
  end

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
  end

  local function with_quickref_dir(callback)
    if not ensure_dir(path) then
      return
    end

    callback()
  end

  local function open_files()
    run_telescope_picker(path, 'find_files', {
      cwd = path,
      hidden = true,
      prompt_title = 'Quickref Files',
    })
  end

  local function open_grep()
    run_telescope_picker(path, 'live_grep', {
      cwd = path,
      prompt_title = 'Quickref Grep',
    })
  end

  create_command('QuickrefFiles', open_files, { desc = 'Find files in quickref repo' })
  create_command('QuickrefGrep', open_grep, { desc = 'Search quickref repo' })
  create_command('QuickrefOpen', function()
    with_quickref_dir(function()
      vim.cmd.edit(vim.fn.fnameescape(path .. '/README.md'))
    end)
  end, { desc = 'Open quickref README' })
  create_command('QuickrefNew', function(opts)
    with_quickref_dir(function()
      new_note(path, opts.args)
    end)
  end, { desc = 'Create quickref note', nargs = '*' })

  map('n', '<leader>sq', open_files, '[S]earch [Q]uickref files')
  map('n', '<leader>sQ', open_grep, '[S]earch [Q]uickref grep')
  map('n', '<leader>qo', '<cmd>QuickrefOpen<CR>', '[Q]uickref [O]pen')
  map('n', '<leader>qn', function()
    vim.ui.input({ prompt = 'Quickref note title: ' }, function(input)
      if input == nil then
        return
      end
      new_note(path, input)
    end)
  end, '[Q]uickref [N]ew note')
end

return M
