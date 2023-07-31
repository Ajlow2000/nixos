local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end


-- Keybinds
    -- Searching
vim.keymap.set("n", "<leader>sf", ":Telescope find_files<cr>", { desc = "[Telescope] - Search for files (fuzzyfind)"})
vim.keymap.set("n", "<leader>sg", ":Telescope git_files<cr>", { desc = "[Telescope] - Search for git files (fuzzyfind)"})
vim.keymap.set("n", "<leader>st", ":Telescope live_grep<cr>", { desc = "[Telescope] - Search for text (ripgrep / live_grep)"})
vim.keymap.set("n", "<leader>sb", ":Telescope buffers<cr>", { desc = "[Telescope] - Search Open Buffers"})
--vim.keymap.set("n", "<leader>sp", ":Telescope projects<cr>", { desc = "[Telescope] - Search Projects"})     -- TODO - depecrate in favor of tmux projects
vim.keymap.set("n", "<leader>sk", ":Telescope keymaps<cr>", { desc = "[Telescope] - Search Keymaps"})
vim.keymap.set("n", "<leader>sm", ":Telescope man_pages<cr>", { desc = "[Telescope] - Search Man Pages"})
vim.keymap.set("n", "<leader>sc", ":Telescope commands<cr>", { desc = "[Telescope] - Search Vim Commands"})
vim.keymap.set("n", "<leader>sr", ":Telescope registers<cr>", { desc = "[Telescope] - Search Registers"})
vim.keymap.set("n", "<leader>sh", ":Telescope help_tags<cr>", { desc = "[Telescope] - Search Help Tags"})
vim.keymap.set("n", "<leader>so", ":Telescope oldfiles<cr>", { desc = "[Telescope] - Search Search Recent Files"})

    -- Colorscheme TODO - add color preview like lvim
vim.keymap.set("n", "<leader>scs", ":Telescope colorscheme<cr>", { desc = "[Telescope] - Browse Colorschemes"})

    -- Git TODO - wrap in pcall to avoid error out
vim.keymap.set("n", "<leader>gb", ":Telescope git_branches<cr>", { desc = "[Telescope] - Checkout Git Branches"})
vim.keymap.set("n", "<leader>gs", ":Telescope git_status<cr>", { desc = "[Telescope] - View Git Status"})
vim.keymap.set("n", "<leader>gc", ":Telescope git_commits<cr>", { desc = "[Telescope] - View Git Commits"})

    -- LSP
vim.keymap.set("n", "<leader>ds", ":Telescope lsp_document_symbols<cr>", { desc = "[Telescope/LSP] - View Document Symbols"})
vim.keymap.set("n", "<leader>ws", ":Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "[Telescope/LSP] - View Dynamic Workspace Symbols"})
vim.keymap.set("n", "<leader>sd", ":Telescope diagnostics bufnr=0<cr>", { desc = "[Telescope/LSP] - View Document Diagnostics"})
vim.keymap.set("n", "<leader>swd", ":Telescope diagnostics<cr>", { desc = "[Telescope/LSP] - View Workspace Diagnostics"})

local actions = require "telescope.actions"

telescope.setup {
    defaults = {
        prompt_prefix = " ",
        selection_caret = "> ",
        path_display = { "smart" },

        mappings = {
            i = {
                ["<C-n>"] = actions.cycle_history_next,
                ["<C-p>"] = actions.cycle_history_prev,

                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,

                ["<esc>"] = actions.close,

                ["<Down>"] = actions.move_selection_next,
                ["<Up>"] = actions.move_selection_previous,

                ["<CR>"] = actions.select_default,
                ["<C-x>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,

                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,

                ["<PageUp>"] = actions.results_scrolling_up,
                ["<PageDown>"] = actions.results_scrolling_down,

                ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                ["<C-l>"] = actions.complete_tag,
                ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
            },

            n = {
                ["<esc>"] = actions.close,
                ["<CR>"] = actions.select_default,
                ["<C-x>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,

                ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                ["j"] = actions.move_selection_next,
                ["k"] = actions.move_selection_previous,
                ["H"] = actions.move_to_top,
                ["M"] = actions.move_to_middle,
                ["L"] = actions.move_to_bottom,

                ["<Down>"] = actions.move_selection_next,
                ["<Up>"] = actions.move_selection_previous,
                ["gg"] = actions.move_to_top,
                ["G"] = actions.move_to_bottom,

                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,

                ["<PageUp>"] = actions.results_scrolling_up,
                ["<PageDown>"] = actions.results_scrolling_down,

                ["?"] = actions.which_key,
            },
        },
    },
    pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
    },
    extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
    },
}
