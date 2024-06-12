--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", { desc = "Nop on space since I use it as leader"})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

COLORSCHEME = vim.env.COLORSCHEME
if COLORSCHEME == nil then COLORSCHEME = "everforest" end
local supported_colorschemes = {
    ["everforest"] = "everforest",
    ["nord"] = "nord",
    ["gruvbox"] = "gruvbox-material",
    ["dracula"] = "dracula",
    ["tokyo-night"] = "tokyonight",
    ["catppuccin"] = "catppuccin",
    ["lackluster"] = "lackluster-hack",
}
COLORSCHEME = supported_colorschemes[COLORSCHEME]

require("ajlow.std.options")
require("ajlow.std.keymaps")
require("ajlow.std.autocommands")
require("ajlow.std.filetypes")
require("ajlow.lazy")

-- Conditionally add a playground file for local testing
--  This playground file is not tracjed/deployed with home manager
--  to allow for local testing without a full HM rebuild.
if is_module_available("ajlow.utils.playground") then
    require("ajlow.utils.playground")
end

