vim.keymap.set(
    {"i"},
    "<C-Space>",
    "<C-x><C-o>",
    { desc = "[std] - Launch Omnifunc Completion" }
)

vim.keymap.set(
    {"i"},
    "<CR>",
    function()
        -- keep standard enter behavior the same when pop up menu is not visible
        if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
        else
            return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
        end
    end,
    { expr = true, desc = "[std] - Accept completion with normal Enter" }
)
