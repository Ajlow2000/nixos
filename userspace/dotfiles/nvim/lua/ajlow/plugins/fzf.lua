return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  opts = {},
    config = function()
        vim.keymap.set(
            "n",
            "<leader>sf",
            ":FzfLua global<cr>",
            {desc = "[fzf] - Search for files and lsp symbols"}
        )

        vim.keymap.set(
            "n",
            "<leader>sb",
            ":FzfLua builtin<cr>",
            {desc = "[fzf] - Search builtin pickers"}
        )
    end
}
