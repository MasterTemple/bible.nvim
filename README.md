# Bible.nvim - Neovim Plugin

## Purpose - Access Bible from within Neovim

![search_example.png](search_example.png)

## Setup

**lazy.nvim**

```lua
{
	"MasterTemple/bible.nvim",
	keys = {
			{"<leader>es", '<cmd>lua require("telescope").extensions.bible.bible()<CR>', desc = "Search by verse content" },
			{"<leader>er", '<cmd>lua require("telescope").extensions.bible.bible_ref()<CR>', desc = "Search by verse reference" },
	}
},
```

## Usage

Hit `Tab` to insert the reference in the line beneath your cursor

Hit `Enter` to insert the content and the reference in the lines beneath your cursor

## Mappings

`<leader>es`: Search by verse content

`<leader>er`: Search by verse reference

## Todo

- Properly lazy load plugin
- Allow user to specify format in setup like: `"{content} [{ref}]"` (options = `book`, `chapter`, `verse`, `ref`, `content`)
- Add proper indentation
- Insert verse content by matching references on current line
- Take what is highlighted as input for Telescope
- Add option to remove unicode apostrophes/quotes
- Add option regarding removing newlines/tabs
- Multi-verse selection
- Allow support for more translations (currently only ESV)
