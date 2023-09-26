local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

config = {
    install = {
        colorscheme = { "everforest" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
}

-- Only generate lockfiles when env var is set
--      This is to limit lockfile creation to manual and for use with git commit hooks
if vim.env.lockfile == "true" then
    config.lockfile = vim.fn.stdpath("config") .. "/lua/" .. PROFILE .. "/lock-lazy.json" -- lockfile generated after running update.
else
    config.lockfile = "/dev/null" -- discard otherwise
end

-- require("lazy").setup({{import = "ajlow.plugins"}, {import = "ajlow.plugins.lsp"}}, {
require("lazy").setup({import = "ajlow.plugins"}, config)

-- TODO: Generate lockfile if flagged
-- if vim.env.lockfile == "true" then
--     vim.cmd "Lazy update"
-- end
