return {
    "nvim-lualine/lualine.nvim",
    dependencies = { 
        "nvim-tree/nvim-web-devicons",
        -- TODO: Add lsp indicator to lualine
        -- "arkav/lualine-lsp-progess",
        -- "nvim-lua/lsp-status.nvim",
    },
    config = function()
        local lualine = require("lualine")

        lualine.setup({
            sections = {
                lualine_c = {
                    -- 'lsp_progress' -- TODO  https://github.com/arkav/lualine-lsp-progress
                    "filename",
                },
                lualine_x = {
                    { "encoding" },
                    { "fileformat" },
                    { "filetype" },
                },
            },
        })
    end,
}
