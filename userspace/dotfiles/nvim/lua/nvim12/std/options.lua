vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 1
vim.opt.mouse = ""
vim.opt.showtabline = 0
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.wrap = false
vim.opt.wrapmargin = 4
vim.opt.linebreak = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.winborder = "rounded"

vim.opt.fileencoding = "utf-8"
vim.opt.conceallevel = 0
vim.opt.pumheight = 10
vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "noselect", "popup"}
vim.opt.termguicolors = true
vim.opt.timeoutlen = 400
vim.opt.updatetime = 750

vim.opt.writebackup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.iskeyword:append "-"                    -- hyphenated words recognized by searches
