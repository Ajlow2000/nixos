--vim.opt.guifont = "monospace:h17"               -- the font used in graphical neovim applications
vim.opt.number = true                           -- set numbered lines
vim.opt.relativenumber = true                   -- set relative numbered lines
vim.opt.cursorline = true                       -- highlight the current line
vim.opt.numberwidth = 4                         -- set number column width to 2 {default 4}
vim.opt.signcolumn = "yes"                      -- always show the sign column, otherwise it would shift the text each time
vim.opt.cmdheight = 1                           -- Control height of 
vim.opt.mouse = "a"                             -- allow the mouse to be used in neovim
vim.opt.showtabline = 0                         -- hide tabline
vim.opt.splitbelow = true                       -- force all horizontal splits to go below current window
vim.opt.splitright = true                       -- force all vertical splits to go to the right of current window

vim.opt.hlsearch = false                        -- highlight all matches on previous search pattern
vim.opt.incsearch = true
vim.opt.ignorecase = true                       -- ignore case in search patterns
vim.opt.smartcase = true                        -- smart case
vim.opt.smartindent = true                      -- make indenting smarter again

vim.opt.expandtab = true                        -- convert tabs to spaces
vim.opt.shiftwidth = 4                          -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4                             -- insert 2 spaces for a tab
vim.opt.wrap = true
vim.opt.wrapmargin = 4 
vim.opt.linebreak = true                        -- companion to wrap, don't split words
vim.opt.scrolloff = 8                           -- minimal number of screen lines to keep above and below the cursor
vim.opt.sidescrolloff = 8                       -- minimal number of screen columns either side of cursor if wrap is `false`

vim.opt.fileencoding = "utf-8"                  -- the encoding written to a file
vim.opt.conceallevel = 0                        -- so that `` is visible in markdown files
vim.opt.pumheight = 10                          -- pop up menu max height
vim.opt.completeopt = { "menuone", "noselect" }  -- mostly just for cmp
vim.opt.termguicolors = true                    -- set term gui colors (most terminals support this)
vim.opt.timeoutlen = 400
vim.opt.updatetime = 750

vim.opt.writebackup = false
vim.opt.undofile = true                         -- enable persistent undo
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.swapfile = false                        -- creates a swapfile
vim.opt.backup = false                          -- creates a backup file
vim.opt.whichwrap = "bs<>[]hl"                  -- which "horizontal" keys are allowed to travel to prev/next line
vim.opt.shortmess:append "c"                           -- don't give |ins-completion-menu| messages
vim.opt.iskeyword:append "-"                           -- hyphenated words recognized by searches

vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")  -- separate vim plugins from neovim in case vim still in use
