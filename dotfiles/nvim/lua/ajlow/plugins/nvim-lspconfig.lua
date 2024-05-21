return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local lspconfig = require('lspconfig')

        -- Global mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { silent = true, desc = "[LSP] - Open Floating Diag" })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true, desc = "[LSP] - Go to prev" })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true, desc = "[LSP] - Go to next" })
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { silent = true, desc = "[LSP] - Set loclist" })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Goto Declaration" })
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Goto definition" })
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, silent = true, desc = "[LSP] - Hover" })
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Goto implementation" })
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Signature Help" })
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Add workspace folder" })
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Remove workspace folder" })
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, { buffer = ev.buf, silent = true, desc = "[LSP] - List workspace folders" })
                vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Goto type definition" })
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Rename" })
                vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Code actions" })
                vim.keymap.set('n', 'gr', vim.lsp.buf.references,
                    { buffer = ev.buf, silent = true, desc = "[LSP] - Goto references" })
                vim.keymap.set('n', '<space>=', function()
                    vim.lsp.buf.format { async = true }
                end, { buffer = ev.buf, silent = true, desc = "[LSP] - Format file" })
            end,
        })

        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        -- used to enable autocompletion (assign to every lsp server config)

        -- Change the Diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Setup language servers.
        lspconfig.nixd.setup { capabilities = capabilities }
        lspconfig.bashls.setup { capabilities = capabilities }
        lspconfig.gopls.setup { capabilities = capabilities }
        lspconfig.ocamllsp.setup { capabilities = capabilities }
        lspconfig.zls.setup { capabilities = capabilities }
        lspconfig.rust_analyzer.setup { capabilities = capabilities }
        lspconfig.pyright.setup { capabilities = capabilities }
        lspconfig.clangd.setup { capabilities = capabilities }
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    diagnostic = {
                        globals = { "vim" },
                        undefined_global = false, -- remove this from diag!
                        missing_parameters = false,
                    },
                    completion = {
                        callSnippet = "Replace"
                    },
                    workspace = {
                        -- make language server aware of runtime files
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                }
            }
        })
    end
}
