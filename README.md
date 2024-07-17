# Bible.nvim - Neovim Plugin

## Purpose - Access Bible from within Neovim

Brief demonstration [here](https://www.youtube.com/watch?v=K8dJbFDudbE)

![search_example.png](search_example.png)


## Setup

### lazy.nvim

#### Install Plugin to Manage Libraries

This ensures that `lsqlite3` and `dkjson` are both installed, which are required to use `bible.nvim`

```lua
{
	"nvim-lua/plenary.nvim",
	dependencies = {
		{
			"theHamsta/nvim_rocks",
			build = "pip3 install --user hererocks && python3 -mhererocks . -j2.1.0-beta3 -r3.0.0 && cp nvim_rocks.lua lua",
			config = function()
				local nvim_rocks = require("nvim_rocks")
				nvim_rocks.ensure_installed("lsqlite3")
				nvim_rocks.ensure_installed("dkjson")
			end,
		},
	},
},
```

#### Install `bible.nvim` Plugin

```lua
{
	"MasterTemple/bible.nvim",
	keys = {
		{"<leader>es", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = false, isMultiSelect = false})<CR>', desc = "Search by verse content" },
		{"<leader>er", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = true, isMultiSelect = false})<CR>', desc = "Search by verse reference" },
		{"<leader>ems", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = false, isMultiSelect = true})<CR>', desc = "Search by verse content (multi-select)" },
		{"<leader>emr", '<cmd>lua require("telescope").extensions.bible.bible({isReferenceOnly = true, isMultiSelect = true})<CR>', desc = "Search by verse reference (multi-select)" },
	}
},
```

## Mappings

### Explanation

Note: I initally chose `e` as the first key because it is in ESV.

These can be remapped in the config above.

`s` is to `s`earch through the content

`r` is to get by `r`eference

Prefix the operation with `m` to make it `m`ulti-select (choose a start and end verse)

`Alt+?` set an option but does not run anything

`Ctrl+?` runs on the current selection

### Open Telescope Menu

`<leader>es`: Search by verse content

`<leader>er`: Search by verse reference

`<leader>ems`: Search by verse content (multi-select)

`<leader>emr`: Search by verse reference (multi-select)

`<leader>et`: Select Bible translation (not implemented yet) [global]

### In Telescope Menu

Hit `Enter` to insert the content and the reference

Hit `Ctrl+W` to insert the whole chapter

Hit `Alt+R` to toggle inserting reference [global: default = true]

Hit `Alt+C` to toggle inserting content [global: default = true]

Hit `Alt+I` to toggle adding indent [global: default = true]

Hit `Alt+S` to toggle showing settings in preview [global: default = true]

Hit `Alt+M` to toggle multi-select [current selection]

Hit `Alt+T` to edit Bible translation (not implemented yet) [current selection]

## Todo

- Ctrl/Shift/Alt+Enter for easier bindings to insert in different formats
- Dynamically size the preview window
- Allow user to specify format in setup like: `"{content} [{ref}]"` (options = `book`, `chapter`, `verse`, `ref`, `content`)
- Insert verse content by matching references on current line (by default set insertReference=false)
	- handle `c:v-v`, `c:v-c:v`, `c:v,v`, and `c:v;c:v`
- Take what is highlighted as input for Telescope
- Add option to remove unicode apostrophes/quotes
- Add option regarding removing newlines/tabs
- Allow support for more translations (currently only ESV) + only download certain ones, not them all
- make config options persist
