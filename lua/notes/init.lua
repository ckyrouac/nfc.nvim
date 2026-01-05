local M = {}

local function get_notes_dir()
  local dir = vim.fn.expand('~/notes.nvim/')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
  return dir
end

local function get_today_filename()
  return os.date('%Y-%m-%d') .. '.md'
end

local function find_previous_notes()
  local notes_dir = get_notes_dir()
  local files = vim.fn.glob(notes_dir .. '*.md', false, true)
  if #files == 0 then
    return nil
  end

  table.sort(files, function(a, b) return a > b end)

  local today = get_today_filename()
  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ':t')
    if filename ~= today then
      return file
    end
  end

  return nil
end

local function parse_incomplete_todos(filepath)
  if not filepath or vim.fn.filereadable(filepath) == 0 then
    return {}
  end

  local lines = vim.fn.readfile(filepath)
  local todos = {}

  for _, line in ipairs(lines) do
    if line:match('^%s*%- %[ %]') then
      table.insert(todos, line)
    end
  end

  return todos
end

local function create_daily_note(todos)
  local date = os.date('%Y-%m-%d')
  local lines = {
    '# Notes for ' .. date,
    '',
    '## Accomplishments',
    '',
    '',
    '## TODO',
  }

  if #todos > 0 then
    for _, todo in ipairs(todos) do
      table.insert(lines, todo)
    end
  else
    table.insert(lines, '- [ ] ')
  end

  return lines
end

function M.open_today()
  local notes_dir = get_notes_dir()
  local filepath = notes_dir .. get_today_filename()

  if vim.fn.filereadable(filepath) == 0 then
    local prev_notes = find_previous_notes()
    local todos = parse_incomplete_todos(prev_notes)
    local content = create_daily_note(todos)
    vim.fn.writefile(content, filepath)
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
end

function M.mark_done()
  local line = vim.api.nvim_get_current_line()
  local new_line = line:gsub('%- %[ %]', '- [x]', 1)

  if new_line ~= line then
    vim.api.nvim_set_current_line(new_line)
  else
    vim.notify('No incomplete TODO on current line', vim.log.levels.WARN)
  end
end

function M.open_picker()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if not ok then
    vim.notify('Telescope is required for :NotesOpen', vim.log.levels.ERROR)
    return
  end

  local notes_dir = get_notes_dir()
  builtin.find_files({
    prompt_title = 'Notes',
    cwd = notes_dir,
    find_command = { 'find', '.', '-name', '*.md', '-type', 'f' },
  })
end

function M.search()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if not ok then
    vim.notify('Telescope is required for :NotesSearch', vim.log.levels.ERROR)
    return
  end

  local notes_dir = get_notes_dir()
  builtin.live_grep({
    prompt_title = 'Search Notes',
    cwd = notes_dir,
  })
end

function M.setup(opts)
  -- Reserved for future configuration options
end

return M
