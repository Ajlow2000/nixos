return {
    "christoomey/vim-tmux-navigator",
    init = function()
        vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
        vim.keymap.set("n", "<A-h>", ":TmuxNavigateLeft<cr>", { silent = true, desc = "[VimTmuxNav] - Navigate Left"})
        vim.keymap.set("n", "<A-j>", ":TmuxNavigateDown<cr>", { silent = true, desc = "[VimTmuxNav] - Navigate Down"})
        vim.keymap.set("n", "<A-k>", ":TmuxNavigateUp<cr>", { silent = true, desc = "[VimTmuxNav] - Navigate Up"})
        vim.keymap.set("n", "<A-l>", ":TmuxNavigateRight<cr>", { silent = true, desc = "[VimTmuxNav] - Navigate Right"})
    end,
}
