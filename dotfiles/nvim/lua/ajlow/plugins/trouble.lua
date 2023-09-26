return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- Lua
        vim.keymap.set("n", "<leader>xx", ":TroubleToggle<cr>", { silent=true, desc = "[Trouble] - Open Trouble"})
        vim.keymap.set("n", "<leader>xw", function() require("trouble").open("workspace_diagnostics") end, { desc = "[Trouble] - Open Workspace Diagnostics"})
        vim.keymap.set("n", "<leader>xd", function() require("trouble").open("document_diagnostics") end, { desc = "[Trouble] - Open Document Diagnostics"})
        vim.keymap.set("n", "<leader>xq", function() require("trouble").open("quickfix") end, { desc = "[Trouble] - Open Quickfix"})
        vim.keymap.set("n", "<leader>xl", function() require("trouble").open("loclist") end, { desc = "[Trouble] - Open Loclist"}) vim.keymap.set("n", "gR", function() require("trouble").open("lsp_references") end, { desc = "[Trouble] - Open LSP References"})
    end,
}
