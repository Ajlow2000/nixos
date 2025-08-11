vim.pack.add({
    -- Colorschemes
    { src = "https://github.com/sainnhe/everforest" },
    { src = "https://github.com/slugbyte/lackluster.nvim" },
    { src = "https://github.com/sainnhe/gruvbox-material" },
    { src = "https://github.com/catppuccin/nvim" },
    { src = "https://github.com/folke/tokyonight.nvim" },
    { src = "https://github.com/shaunsingh/nord.nvim" },

    -- Icons
    { src = "https://github.com/echasnovski/mini.icons" },

    -- FZF
    { src = "https://github.com/ibhagwan/fzf-lua" },

    -- Treesitter
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
    },

    -- nvim-cmp completion
    "https://github.com/hrsh7th/nvim-cmp",
    "https://github.com/hrsh7th/cmp-buffer",
    "https://github.com/hrsh7th/cmp-path",
    "https://github.com/hrsh7th/cmp-nvim-lsp",
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/saadparwaiz1/cmp_luasnip",
    "https://github.com/rafamadriz/friendly-snippets",
    "https://github.com/onsails/lspkind.nvim",
})

require(PROFILE .. ".plugins.colors")
require(PROFILE .. ".plugins.fzf")
require(PROFILE .. ".plugins.treesitter")
require(PROFILE .. ".plugins.navigator")
require(PROFILE .. ".plugins.nvim-cmp")

-- Configure LSP servers
vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
})

vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json" },
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                loadOutDirsFromCheck = true,
            },
            procMacro = {
                enable = true,
            },
            diagnostics = {
                enable = true,
            },
        },
    },
})

vim.lsp.config("zls", {
    cmd = { "zls" },
    filetypes = { "zig" },
    root_markers = { "build.zig", ".git" },
})

vim.lsp.config("clangd", {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" },
    capabilities = {
        offsetEncoding = { "utf-16" },
    },
})

vim.lsp.config("ocamllsp", {
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    root_markers = { "*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace" },
})

vim.lsp.config("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
        },
    },
})

vim.lsp.config("hls", {
    cmd = { "haskell-language-server-wrapper", "--lsp" },
    filetypes = { "haskell", "lhaskell" },
    root_markers = { "*.cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml", ".git" },
})

vim.lsp.config("pyright", {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            },
        },
    },
})

vim.lsp.config("bashls", {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash" },
    root_markers = { ".git" },
})

-- Enable LSP servers
vim.lsp.enable({
    "lua_ls",
    "rust_analyzer",
    "zls",
    "clangd",
    "ocamllsp",
    "gopls",
    "hls",
    "pyright",
    "bashls"
})
