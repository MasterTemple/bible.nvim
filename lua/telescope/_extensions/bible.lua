local telescope = require('telescope')
local my_extension = require('telescope._extensions.bible.bible')

return telescope.register_extension({
  exports = {
    my_extension = my_extension,
  }
})
