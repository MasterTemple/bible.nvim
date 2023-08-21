# Bible.nvim - Neovim Plugin

## Purpose - Access Bible from within Neovim

![search_example.png](search_example.png)

## Setup

**lazy.nvim**

```lua
{
	"MasterTemple/bible.nvim",
	lazy = false,
	config = function()
		require("telescope").load_extension "bible"
		require("telescope").load_extension "bible_ref"
	end,
},
```

Note: I haven't yet learned how to make everything lazy load

## Usage

Hit `Tab` to insert the reference in the line beneath your cursor

Hit `Enter` to insert the content and the reference in the lines beneath your cursor

## Mappings

```lua
["<leader>es"] = { '<cmd>Telescope bible<CR>', "Search by verse content" },
["<leader>er"] = { '<cmd>Telescope bible_ref<CR>', "Search by verse reference" },
```

## Todo

- Fix path issues
- Properly lazy load plugin
- Allow user to specify format in setup like: `"{content} [{ref}]"`
- Allow support for more translations (currently only ESV)
