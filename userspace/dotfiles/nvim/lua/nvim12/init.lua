--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", { desc = "[std] - nop on space since I use it as leader"})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require(PROFILE .. ".std.options")
require(PROFILE .. ".std.keymaps")
require(PROFILE .. ".std.autocommands")
require(PROFILE .. ".std.filetypes")
require(PROFILE .. ".std.completion")
require(PROFILE .. ".plugins")

-- Conditionally add a playground file for local testing
--      This playground file is not tracked/deployed with home manager
--      to allow for local testing without a full HM rebuild.
if is_module_available("ajlow.utils.playground") then
    require("ajlow.utils.playground")
end
