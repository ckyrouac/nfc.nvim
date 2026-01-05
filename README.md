# nfc.nvim

**Notes for Chris** - A Neovim plugin for streamlined daily note-taking with automatic TODO carry-forward.

> This entire plugin was vibe coded using [Claude Code](https://claude.com/claude-code) with Claude Opus 4.5. From initial concept to final implementation, every line of code was generated through natural conversation.

## Features

- Daily notes stored as markdown files (`YYYY-MM-DD.md`)
- Automatic carry-forward of incomplete TODOs to new days
- Multiple named TODO lists (e.g., Work, Personal)
- Toggle TODO completion with automatic Accomplishments sync
- Telescope integration for browsing and searching notes
- Context-aware TODO addition (adds to current list when cursor is in a TODO section)

## Requirements

- Neovim >= 0.8.0
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (optional, for `:NotesOpen`, `:NotesSearch`, and `:NotesTodoPick`)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ckyrouac/nfc.nvim",
  opts = {
    notes_dir = "~/notes/",
    default_todo_list = "Work",
  },
}
```

Or for a local development copy:

```lua
{
  dir = "~/projects/nfc.nvim",
  opts = {
    notes_dir = "~/notes/",
    default_todo_list = "Work",
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "ckyrouac/nfc.nvim",
  config = function()
    require("notes").setup({
      notes_dir = "~/notes/",
      default_todo_list = "Work",
    })
  end,
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ckyrouac/nfc.nvim'

" In your init.vim or after/plugin:
lua require("notes").setup({ notes_dir = "~/notes/", default_todo_list = "Work" })
```

### [mini.deps](https://github.com/echasnovski/mini.deps)

```lua
MiniDeps.add({ source = "ckyrouac/nfc.nvim" })
require("notes").setup({
  notes_dir = "~/notes/",
  default_todo_list = "Work",
})
```

## Configuration

```lua
require("notes").setup({
  -- Directory where notes are stored (default: ~/notes.nvim/)
  notes_dir = "~/notes/",

  -- Default TODO list name for :NotesTodo when not in a TODO section
  -- Set to nil for unnamed default list, or a string like "Work"
  default_todo_list = "Work",
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:Notes` | Open today's notes, creating the file if it doesn't exist. Incomplete TODOs from the previous day are automatically copied. |
| `:NotesMarkDone` | Toggle the TODO item on the current line between `[ ]` and `[x]`. When marking done, the task is copied to Accomplishments. When unmarking, it's removed from Accomplishments. |
| `:NotesTodo [list]` | Add a new TODO item. If `list` is provided, adds to that list. Otherwise, adds to the list under the cursor (if in today's notes) or the default list. |
| `:NotesTodoPick` | Open a Telescope picker to select which TODO list to add a new item to. |
| `:NotesOpen` | Open a Telescope picker to browse and open any notes file. |
| `:NotesSearch` | Live grep through all notes content using Telescope. |

## Default Keymaps

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>nn` | `:Notes` | Open today's notes |
| `<leader>nd` | `:NotesMarkDone` | Toggle TODO done state |
| `<leader>nt` | `:NotesTodo` | Add a new TODO item |
| `<leader>np` | `:NotesTodoPick` | Pick TODO list to add item |

## File Format

Each daily note follows this structure:

```markdown
# Notes for 2026-01-05

## Accomplishments
- Completed task from TODO

## TODO (Work)
- [ ] Incomplete work task
- [x] Completed work task

## TODO (Personal)
- [ ] Incomplete personal task
```

### Multiple TODO Lists

You can have multiple named TODO lists in a single day's notes. Lists are created automatically when you use `:NotesTodo listname` or select a list via `:NotesTodoPick`.

Named lists use the format `## TODO (ListName)`, while the default unnamed list uses `## TODO`.

### Automatic TODO Carry-Forward

When you open a new day's notes with `:Notes`, all incomplete TODOs (`- [ ]`) from the previous day are automatically copied to the new file. This ensures nothing falls through the cracks.

### Accomplishments Sync

When you mark a TODO as done with `:NotesMarkDone`, the task text is automatically added to the Accomplishments section. If you toggle it back to incomplete, it's removed from Accomplishments.

## License

MIT
