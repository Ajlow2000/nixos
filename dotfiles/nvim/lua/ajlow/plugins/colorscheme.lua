return {
    {
        "sainnhe/everforest",
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.cmd("colorscheme " .. COLORSCHEME)
        end,
    },
    { "shaunsingh/nord.nvim", priority = 1000 },
    { "sainnhe/gruvbox-material", priority = 1000  },
    { "catppuccin/nvim", priority = 1000  },
    { "folke/tokyonight.nvim", priority = 1000  },
    { "Mofiqul/dracula.nvim", priority = 1000  },
    { "slugbyte/lackluster.nvim", priority = 1000  },
}
