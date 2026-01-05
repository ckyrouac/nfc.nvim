local M = {}

local config = {
  default_todo_list = nil,
}

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

local function make_todo_header(list_name)
  if list_name then
    return '## TODO (' .. list_name .. ')'
  else
    return '## TODO'
  end
end

local function parse_todo_sections(filepath)
  if not filepath or vim.fn.filereadable(filepath) == 0 then
    return {}
  end

  local lines = vim.fn.readfile(filepath)
  local sections = {}
  local current_list = nil

  for _, line in ipairs(lines) do
    local named_list = line:match('^## TODO %((.+)%)%s*$')
    local default_list = line:match('^## TODO%s*$')

    if named_list then
      current_list = named_list
      if not sections[current_list] then
        sections[current_list] = {}
      end
    elseif default_list then
      current_list = ''
      if not sections[current_list] then
        sections[current_list] = {}
      end
    elseif line:match('^#') then
      current_list = nil
    elseif current_list and line:match('^%s*%- %[ %]') then
      table.insert(sections[current_list], line)
    end
  end

  return sections
end

local function create_daily_note(todo_sections)
  local date = os.date('%Y-%m-%d')
  local lines = {
    '# Notes for ' .. date,
    '',
    '## Accomplishments',
    '',
    '',
  }

  local has_sections = false
  for _ in pairs(todo_sections) do
    has_sections = true
    break
  end

  if has_sections then
    local sorted_names = {}
    for name in pairs(todo_sections) do
      table.insert(sorted_names, name)
    end
    table.sort(sorted_names)

    for _, name in ipairs(sorted_names) do
      local header = make_todo_header(name ~= '' and name or nil)
      table.insert(lines, header)
      for _, todo in ipairs(todo_sections[name]) do
        table.insert(lines, todo)
      end
      table.insert(lines, '')
    end
  else
    table.insert(lines, '## TODO')
    table.insert(lines, '- [ ] ')
  end

  return lines
end

function M.open_today()
  local notes_dir = get_notes_dir()
  local filepath = notes_dir .. get_today_filename()

  if vim.fn.filereadable(filepath) == 0 then
    local prev_notes = find_previous_notes()
    local todo_sections = parse_todo_sections(prev_notes)
    local content = create_daily_note(todo_sections)
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

local function get_todo_list_names()
  local notes_dir = get_notes_dir()
  local today_path = notes_dir .. get_today_filename()
  local filepath = today_path

  if vim.fn.filereadable(filepath) == 0 then
    filepath = find_previous_notes()
  end

  if not filepath then
    return {}
  end

  local lines = vim.fn.readfile(filepath)
  local names = {}

  for _, line in ipairs(lines) do
    local named_list = line:match('^## TODO %((.+)%)%s*$')
    local default_list = line:match('^## TODO%s*$')

    if named_list then
      table.insert(names, named_list)
    elseif default_list then
      table.insert(names, '')
    end
  end

  return names
end

function M.add_todo(list_name)
  list_name = list_name or config.default_todo_list

  local notes_dir = get_notes_dir()
  local today_path = notes_dir .. get_today_filename()
  local current_file = vim.fn.expand('%:p')

  if current_file ~= today_path then
    M.open_today()
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local target_header = make_todo_header(list_name)
  local todo_line = nil

  for i, line in ipairs(lines) do
    if line == target_header then
      todo_line = i
      break
    end
  end

  if not todo_line then
    local last_line = #lines
    vim.api.nvim_buf_set_lines(0, last_line, last_line, false, { '', target_header, '- [ ] ' })
    vim.api.nvim_win_set_cursor(0, { last_line + 3, 6 })
    vim.schedule(function()
      vim.cmd('startinsert!')
    end)
    return
  end

  local insert_line = todo_line
  for i = todo_line + 1, #lines do
    if lines[i]:match('^#') or lines[i]:match('^%s*$') then
      break
    end
    insert_line = i
  end

  vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { '- [ ] ' })
  vim.api.nvim_win_set_cursor(0, { insert_line + 1, 6 })
  vim.schedule(function()
    vim.cmd('startinsert!')
  end)
end

function M.pick_todo_list()
  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    vim.notify('Telescope is required for todo list picker', vim.log.levels.ERROR)
    return
  end

  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local list_names = get_todo_list_names()
  local display_names = {}

  for _, name in ipairs(list_names) do
    if name == '' then
      table.insert(display_names, '(default)')
    else
      table.insert(display_names, name)
    end
  end

  if #display_names == 0 then
    table.insert(display_names, '(default)')
    table.insert(list_names, '')
  end

  pickers.new({}, {
    prompt_title = 'Select TODO List',
    finder = finders.new_table({
      results = display_names,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local idx = selection.index
          local selected_name = list_names[idx]
          M.add_todo(selected_name ~= '' and selected_name or nil)
        end
      end)
      return true
    end,
  }):find()
end

function M.setup(opts)
  opts = opts or {}
  if opts.default_todo_list ~= nil then
    config.default_todo_list = opts.default_todo_list
  end
end

return M
