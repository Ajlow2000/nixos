return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        -- Global mappings.
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { silent = true, desc = "[LSP] - Open Floating Diag" })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true, desc = "[LSP] - Go to prev" })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true, desc = "[LSP] - Go to next" })
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { silent = true, desc = "[LSP] - Set loclist" })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
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

        -- Change the Diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Set capabilities globally for all servers
        vim.lsp.config('*', { capabilities = capabilities })

        -- Servers with custom settings
        vim.lsp.config('rust_analyzer', {
            settings = {
                ['rust-analyzer'] = {
                    diagnostics = {
                        disabled = { 'inactive-code' }
                    }
                }
            }
        })
        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    diagnostic = {
                        globals = { "vim" },
                        undefined_global = false,
                        missing_parameters = false,
                    },
                    completion = {
                        callSnippet = "Replace"
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                }
            }
        })
        vim.lsp.config('omnisharp', { cmd = { "OmniSharp" } })
        vim.lsp.config('tinymist', {
            settings = {
                exportPdf = "onType"
            }
        })

        -- Enable all servers
        vim.lsp.enable({
            'nil_ls', 'bashls', 'gopls', 'templ', 'html',
            'ocamllsp', 'zls', 'rust_analyzer', 'pyright',
            'clangd', 'hls', 'marksman', 'asm_lsp', 'lua_ls',
            'omnisharp', 'tinymist',
        })
    end
}
