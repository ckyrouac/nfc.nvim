if vim.g.loaded_notes then
  return
end
vim.g.loaded_notes = true

vim.api.nvim_create_user_command('Notes', function()
  require('notes').open_today()
end, { desc = 'Open today\'s notes' })

vim.api.nvim_create_user_command('NotesMarkDone', function()
  require('notes').mark_done()
end, { desc = 'Mark current TODO as done' })

vim.api.nvim_create_user_command('NotesOpen', function()
  require('notes').open_picker()
end, { desc = 'Open notes picker' })

vim.api.nvim_create_user_command('NotesSearch', function()
  require('notes').search()
end, { desc = 'Search notes content' })

vim.api.nvim_create_user_command('NotesTodo', function()
  require('notes').add_todo()
end, { desc = 'Add a new TODO item' })
