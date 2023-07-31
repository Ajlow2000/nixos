local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- TODO refactor autocmd to lua
-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Plugins here
return packer.startup(function(use)
    -- Basics
    use { "wbthomason/packer.nvim" }
    use { "nvim-lua/plenary.nvim" }
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", requires = {
            "nvim-treesitter/nvim-treesitter-context",
            "nvim-treesitter/playground",
        }
    }
    use { "nvim-telescope/telescope.nvim", tag = "0.1.0" }
    use { "numToStr/Comment.nvim" }
    use { "folke/todo-comments.nvim", requires = "nvim-lua/plenary.nvim" }
    use { "mbbill/undotree" }
    use { "folke/zen-mode.nvim" }
    use { "folke/twilight.nvim" }
    use { "windwp/nvim-autopairs" }
    use { "ThePrimeagen/harpoon" }
    use { "ggandor/leap.nvim" }
    use { "chrisbra/Colorizer" }
    use { "christoomey/vim-tmux-navigator" }
    use { "folke/which-key.nvim" }
    use { "stevearc/oil.nvim" }
    use { "RaafatTurki/hex.nvim", config = function() require("hex").setup() end}

    -- Lsp 
    use {
        "VonHeikemen/lsp-zero.nvim",
        requires = {
            -- LSP Support
            {"neovim/nvim-lspconfig"},
            {"williamboman/mason.nvim"},
            {"williamboman/mason-lspconfig.nvim"},

            -- Autocompletion
            {"hrsh7th/nvim-cmp"},
            {"hrsh7th/cmp-buffer"},
            {"hrsh7th/cmp-path"},
            {"saadparwaiz1/cmp_luasnip"},
            {"hrsh7th/cmp-nvim-lsp"},
            {"hrsh7th/cmp-nvim-lua"},

            -- Snippets
            {"L3MON4D3/LuaSnip"},
            {"rafamadriz/friendly-snippets"},
        }
    }

    -- Debugging
    use { "mfussenegger/nvim-dap" }
    use { "rcarriga/nvim-dap-ui" }
    use { "nvim-telescope/telescope-dap.nvim" }
    use { "theHamsta/nvim-dap-virtual-text" }

        -- Colorschemes
    use { "shaunsingh/nord.nvim" }
    use { "morhetz/gruvbox" }
    use { "sainnhe/everforest" }
    use { "catppuccin/nvim" }
    use { "folke/tokyonight.nvim" }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
