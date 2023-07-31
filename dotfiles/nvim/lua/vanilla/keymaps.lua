--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", { desc = "Nop on space since I use it as leader"})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.tmux_navigator_no_mappings = 1

vim.keymap.set(
    "n",
    "<C-l>",
    "20zl",
    { silent = false, desc = "Horizontal Scroll"}
)

vim.keymap.set(
    "n",
    "<C-h>",
    "20zh",
    { silent = false, desc = "Horizontal Scroll"}
)

vim.keymap.set(
    "n", 
    "<A-h>",
    ":TmuxNavigateLeft<cr>", 
    { silent = true, desc = "[VimTmuxNav] - Navigate Left"}
)

vim.keymap.set(
    "n",
    "<A-j>",
    ":TmuxNavigateDown<cr>",
    { silent = true, desc = "[VimTmuxNav] - Navigate Left"}
)

vim.keymap.set(
    "n",
    "<A-k>",
    ":TmuxNavigateUp<cr>",
    { silent = true, desc = "[VimTmuxNav] - Navigate Left"}
)

vim.keymap.set("n",
    "<A-l>",
    ":TmuxNavigateRight<cr>",
    { silent = true, desc = "[VimTmuxNav] - Navigate Left"}
)

vim.keymap.set(
    "n",
    "<leader>cc",
    function()
        local value = vim.api.nvim_get_option_value("colorcolumn", {})
        if value == "" then
            vim.api.nvim_set_option_value("colorcolumn", "80", {})
        else
            vim.api.nvim_set_option_value("colorcolumn", "", {})
        end
    end,
    { desc = "Toggle Line 80 Indicator on and off" }
)

vim.keymap.set(
    "n",
    "Q",
    "<nop>",
    { desc = "'Worst place in the universe' -ThePrimeagen"}
)

vim.keymap.set(
    "n",
    "<leader>/",
    ":nohlsearch<cr>",
    { desc = "Clear Search Highlighting" }
)

vim.keymap.set(
    "n",
    "<leader>rw",
    ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
    { desc = "Start replacing all instances of word under cursor within file"}
)


vim.keymap.set(
    "n",
    "<leader>po",
    '"_dP',
    { desc = "Paste over visual selection without recoping the deleted selection" }
)

vim.keymap.set(
    {"n",
    "v"},
    "<leader>sy",
    '\"+y', { desc = "Yank to system clipboard"}
)

vim.keymap.set(
    "n",
    "<leader>sY",
    '\"+Y',
    { desc = "Yank to system clipboard"}
)

vim.keymap.set(
    "n",
    "<leader>sp",
    '"+gp',
    { desc = "Paste from system clipboard"}
)

vim.keymap.set(
    {"n",
    "v"},
    "<leader>vd",
    '\"_d', { desc = "Delete to void register"}
)


vim.keymap.set(
    "n",
    "<leader>q",
    ":bd<cr>",
    { desc = "Close Buffer"}
)

vim.keymap.set(
    "n",
    "<S-l>",
    ":bnext<CR>",
    { desc = "Cycle forwards through buffers" }
)

vim.keymap.set(
    "n",
    "<S-h>",
    ":bprevious<CR>",
    { desc = "Cycle backwards through buffers" }
)


vim.keymap.set(
    "n",
    "<C-d>",
    "<C-d>zz",
    { desc = "Jump down half page with cursor centered"}
)

vim.keymap.set(
    "n",
    "<C-u>",
    "<C-u>zz",
    { desc = "Jump up half page with cursor centered"}
)


vim.keymap.set(
    "n",
    "n",
    "nzzzv",
    { desc = "Jump to next search result with cursor centered"}
)

vim.keymap.set(
    "n",
    "N",
    "Nzzzv",
    { desc = "Jump to previous search result with cursor centered"}
)


vim.keymap.set(
    "n",
    "<C-Up>",
    ":resize +2<CR>",
    { desc = "Resize split vertically (larger)" } 
)

vim.keymap.set(
    "n",
    "<C-Down>",
    ":resize -2<CR>",
    { desc = "Resize split vertically (smaller)" } 
)

vim.keymap.set(
    "n",
    "<C-Left>",
    ":vertical resize -2<CR>",
    { desc = "Resize split horizontally (smaller)" } 
)

vim.keymap.set(
    "n",
    "<C-Right>",
    ":vertical resize +2<CR>",
    { desc = "Resize split horizontally (larger)" }
)


vim.keymap.set(
    "v",
    ">",
    ">gv",
    { desc = "Increment Indentation of visual selection" }
)

vim.keymap.set(
    "v",
    "<",
    "<gv",
    { desc = "Decrement Indentation of visual selection" }
)


vim.keymap.set(
    "v",
    "J",
    ":m '>+1<CR>gv=gv",
    { desc = "Move visual selection down (with auto indent)"}
)

vim.keymap.set(
    "v",
    "K",
    ":m '<-2<CR>gv=gv",
    { desc = "Move visual selection down (with auto indent)"}
)

