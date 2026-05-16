return {
    "folke/zen-mode.nvim",
    config = function()
        require("zen-mode").setup({
            window = {
                backdrop = 0.75,
                width = 80,
                height = .95,
                options = {
                    signcolumn = "no",
                    number = false,
                    relativenumber = false,
                    cursorline = false,
                    foldcolumn = "0",
                    wrap = true,
                    linebreak = true,
                },
            },
            plugins = {
                options = {
                    enabled = true,
                    laststatus = 0,
                },
                gitsigns = { enabled = false },
                tmux = { enabled = false },
                todo = { enabled = false },
            },
            on_open = function()
                vim.keymap.set("n", "j", "gj", { buffer = true })
                vim.keymap.set("n", "k", "gk", { buffer = true })
            end,
            on_close = function()
                vim.keymap.del("n", "j", { buffer = true })
                vim.keymap.del("n", "k", { buffer = true })
            end,
        })

        vim.keymap.set("n", "<leader>z", function()
            require("zen-mode").toggle()
        end, { desc = "[ZenMode] - Toggle Zen Mode" })

        -- NOTE: disabling because its annoying to :wqa when I open one md file...  
        -- vim.api.nvim_create_autocmd("BufWinEnter", {
        --     pattern = "*.md",
        --     callback = function()
        --         vim.schedule(function()
        --             require("zen-mode").open()
        --         end)
        --     end,
        -- })
    end,
}
