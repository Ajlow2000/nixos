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
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count

        lualine.setup({
            sections = {
                lualine_c = {
                    -- 'lsp_progress' -- TODO  https://github.com/arkav/lualine-lsp-progress
                    "filename",
                },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    { "encoding" },
                    { "fileformat" },
                    { "filetype" },
                },
            },
        })
    end,
}
