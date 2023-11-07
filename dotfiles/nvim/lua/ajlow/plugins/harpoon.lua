return {
    "ThePrimeagen/harpoon",
    config = function()
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        require("harpoon").setup({
            global_settings = {
                -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
                save_on_toggle = false,

                -- saves the harpoon file upon every change. disabling is unrecommended.
                save_on_change = true,

                -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
                enter_on_sendcmd = false,

                -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
                tmux_autoclose_windows = true,

                -- filetypes that you want to prevent from adding to the harpoon list menu.
                excluded_filetypes = { "harpoon" },

                -- set marks specific to each git branch inside git repository
                mark_branch = false,
            }
        })

        vim.keymap.set("n", "<leader>h", ":lua require('harpoon.ui').toggle_quick_menu()<cr>", { desc = "[Harpoon] - Toggle Harpoon Menu", silent = true })
        vim.keymap.set("n", "<leader>hh", ":lua require('harpoon.mark').add_file()<cr>", { desc = "[Harpoon] - Add file to harpoon" })
        vim.keymap.set("n", "<leader>f", ":lua require('harpoon.ui').nav_file(1)<cr>", { desc = "[Harpoon] - Navigate to file 1" } )
        vim.keymap.set("n", "<leader>d", ":lua require('harpoon.ui').nav_file(2)<cr>", { desc = "[Harpoon] - Navigate to file 2" } )
        vim.keymap.set("n", "<leader>s", ":lua require('harpoon.ui').nav_file(3)<cr>", { desc = "[Harpoon] - Navigate to file 3" } )
        vim.keymap.set("n", "<leader>a", ":lua require('harpoon.ui').nav_file(4)<cr>", { desc = "[Harpoon] - Navigate to file 4" } )
        -- vim.keymap.set("n", "<C-l>", ":lua require('harpoon.ui').nav_next()<cr>", { desc="[Harpoon] - Navigate to next Harpoon file"})
        -- vim.keymap.set("n", "<C-h>", ":lua require('harpoon.ui').nav_prev()<cr>", { desc = "[Harpoon] - Navigate to previous Harpoon file"}) require('harpoon.ui').toggle_quick_menu()
    end
}
