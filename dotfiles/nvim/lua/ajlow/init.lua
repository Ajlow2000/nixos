--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", { desc = "Nop on space since I use it as leader"})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("ajlow.utils.debug")
require("ajlow.utils.custom")
require("ajlow.std.options")
require("ajlow.std.keymaps")
require("ajlow.std.autocommands")
require("ajlow.std.filetypes")
require("ajlow.lazy")

-- Conditionally add a playground file for local testing
--  This playground file is not tracked/deployed with home manager
--  to allow for local testing without a full HM rebuild.
--  NOTE: additions to playground will not be tracked with VCS
if is_module_available("ajlow.utils.playground") then
    require("ajlow.utils.playground")
end

