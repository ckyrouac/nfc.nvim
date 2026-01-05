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
