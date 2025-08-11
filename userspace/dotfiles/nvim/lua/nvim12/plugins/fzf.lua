vim.pack.add({
    {src = "https://github.com/ibhagwan/fzf-lua"},
})

require('fzf-lua').setup({'fzf-native'})

vim.keymap.set(
    "n",
    "<leader>sf",
    ":FzfLua global<cr>",
    {desc = "[fzf] - Search for files and lsp symbols"}
)

vim.keymap.set(
    "n",
    "<leader>g",
    ":FzfLua live_grep<cr>",
    {desc = "[fzf] - Search for text matches"}
)

vim.keymap.set(
    "n",
    "<leader>sb",
    ":FzfLua builtin<cr>",
    {desc = "[fzf] - Search builtin pickers"}
)
