--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", { desc = "Nop on space since I use it as leader"})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("ajlow.std.options")
require("ajlow.std.keymaps")
require("ajlow.std.autocommands")
require("ajlow.lazy")
require("ajlow.debug-utils")
