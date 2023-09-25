local status_ok, lsp = pcall(require, "lsp-zero")
if not status_ok then
    return
end


lsp.preset('recommended')

lsp.ensure_installed({
})

lsp.nvim_workspace()

lsp.set_preferences({
    sign_icons = { }
})

lsp.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "[LSP] - Toggle Hover Menu"})
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format{async=true} end, { desc = "[LSP] - Format with LSP"} )
    vim.keymap.set("n", "<leader>d", function() vim.diagnostic.open_float() end, { desc = "[LSP] - Open diagnostic float"} )
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "[LSP] - Goto definition"})
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, { desc = "[LSP] - Goto next diagnostic]"} )
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, { desc = "[LSP] - Goto prev diagnostic"} )
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "[LSP] - Open code actions in quickfix"} )
    vim.keymap.set("n", "<leader>vr", function() vim.lsp.buf.references() end, { desc = "[LSP] - View references"} )
    vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.rename() end, { desc = "[LSP] - LSP Rename"} )
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, { desc = "[LSP] - Signature Help"} )

end)

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = true,
})
