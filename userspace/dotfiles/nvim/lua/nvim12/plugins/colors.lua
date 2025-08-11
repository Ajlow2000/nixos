
COLORSCHEME = vim.env.COLORSCHEME
if COLORSCHEME == nil then COLORSCHEME = "gruvbox" end
local supported_colorschemes = {
    ["default"] = "default",
    ["everforest"] = "everforest",
    ["nord"] = "nord",
    ["gruvbox"] = "gruvbox-material",
    ["dracula"] = "dracula",
    ["tokyo-night"] = "tokyonight",
    ["catppuccin"] = "catppuccin",
    ["lackluster"] = "lackluster-hack",
}
COLORSCHEME = supported_colorschemes[COLORSCHEME]

vim.cmd("colorscheme " .. COLORSCHEME)
