
return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
        "debugloop/telescope-undo.nvim",
        "nvim-telescope/telescope-ui-select.nvim"
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                path_display = { "truncate " },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                        ["<C-j>"] = actions.move_selection_next, -- move to next result
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
            extensions = {
                -- undo = {
                --     side_by_side = true,
                --     layout_strategy = "vertical",
                --     layout_config = {
                --         preview_height = 0.8,
                --     },
                -- },
            },
        })
        require("telescope").load_extension("undo")

        -- This is your opts table
        require("telescope").setup {
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {
                        -- even more opts
                    }
                    -- pseudo code / specification for writing custom displays, like the one
                    -- for "codeactions"
                    -- specific_opts = {
                    --   [kind] = {
                    --     make_indexed = function(items) -> indexed_items, width,
                    --     make_displayer = function(widths) -> displayer
                    --     make_display = function(displayer) -> function(e)
                    --     make_ordinal = function(e) -> string
                    --   },
                    --   -- for example to disable the custom builtin "codeactions" display
                    --      do the following
                    --   codeactions = false,
                    -- }
                }
            }
        }
        -- To get ui-select loaded and working with telescope, you need to call
        -- load_extension, somewhere after setup function:
        require("telescope").load_extension("ui-select")

        telescope.load_extension("fzf")

        -- <><><> set keymaps <><><>

        -- Searching
        vim.keymap.set("n", "<leader>sf", ":Telescope find_files<cr>", { desc = "[Telescope] - Search for files (fuzzyfind)"})
        vim.keymap.set("n", "<leader>sg", ":Telescope git_files<cr>", { desc = "[Telescope] - Search for git files (fuzzyfind)"})
        vim.keymap.set("n", "<leader>rg", ":Telescope live_grep<cr>", { desc = "[Telescope] - Search for text (ripgrep / live_grep)"})
        vim.keymap.set("n", "<leader>sb", ":Telescope buffers<cr>", { desc = "[Telescope] - Search Open Buffers"})
        --vim.keymap.set("n", "<leader>sp", ":Telescope projects<cr>", { desc = "[Telescope] - Search Projects"})     -- TODO - depecrate in favor of tmux projects
        vim.keymap.set("n", "<leader>sk", ":Telescope keymaps<cr>", { desc = "[Telescope] - Search Keymaps"})
        vim.keymap.set("n", "<leader>sm", ":Telescope man_pages<cr>", { desc = "[Telescope] - Search Man Pages"})
        vim.keymap.set("n", "<leader>sc", ":Telescope commands<cr>", { desc = "[Telescope] - Search Vim Commands"})
        vim.keymap.set("n", "<leader>sr", ":Telescope registers<cr>", { desc = "[Telescope] - Search Registers"})
        vim.keymap.set("n", "<leader>sh", ":Telescope help_tags<cr>", { desc = "[Telescope] - Search Help Tags"})
        vim.keymap.set("n", "<leader>so", ":Telescope oldfiles<cr>", { desc = "[Telescope] - Search Search Recent Files"})
        vim.keymap.set("n", "<leader>su", ":Telescope undo theme=dropdown<cr>", { desc = "[Telescope] - Undo History"})

        -- Colorscheme TODO - add color preview like lvim
        vim.keymap.set("n", "<leader>scs", ":Telescope colorscheme<cr>", { desc = "[Telescope] - Browse Colorschemes"})

        -- Git TODO - wrap in pcall to avoid error out
        vim.keymap.set("n", "<leader>gb", ":Telescope git_branches<cr>", { desc = "[Telescope] - Checkout Git Branches"})
        vim.keymap.set("n", "<leader>gs", ":Telescope git_status<cr>", { desc = "[Telescope] - View Git Status"})
        vim.keymap.set("n", "<leader>gc", ":Telescope git_commits<cr>", { desc = "[Telescope] - View Git Commits"})

        -- LSP
        vim.keymap.set("n", "<leader>sds", ":Telescope lsp_document_symbols<cr>", { desc = "[Telescope/LSP] - View Document Symbols"})
        vim.keymap.set("n", "<leader>ws", ":Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "[Telescope/LSP] - View Dynamic Workspace Symbols"})
        vim.keymap.set("n", "<leader>sd", ":Telescope diagnostics bufnr=0<cr>", { desc = "[Telescope/LSP] - View Document Diagnostics"})
        vim.keymap.set("n", "<leader>swd", ":Telescope diagnostics<cr>", { desc = "[Telescope/LSP] - View Workspace Diagnostics"})
    end,
}
