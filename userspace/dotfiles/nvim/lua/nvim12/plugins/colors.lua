vim.pack.add({
    {src = "https://github.com/sainnhe/everforest"},
    {src = "https://github.com/slugbyte/lackluster.nvim"},
    {src = "https://github.com/sainnhe/gruvbox-material"},
    {src = "https://github.com/catppuccin/nvim"},
    {src = "https://github.com/folke/tokyonight.nvim"},
    {src = "https://github.com/shaunsingh/nord.nvim"},
})

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
