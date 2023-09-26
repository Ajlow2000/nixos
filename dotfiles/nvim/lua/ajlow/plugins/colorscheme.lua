return {
    {
        "sainnhe/everforest",
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme everforest]])
        end,
    },
    { "shaunsingh/nord.nvim" },
    { "morhetz/gruvbox" },
    { "sainnhe/everforest" },
    { "catppuccin/nvim" },
    { "folke/tokyonight.nvim" },
}
