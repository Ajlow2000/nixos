-- TODO - rewrite in lua
vim.cmd [[
    augroup _general_settings
      autocmd!
      autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR> 
      autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 40}) 
      autocmd BufWinEnter * lua vim.opt.formatoptions:remove({"c", "o", "t"})
      autocmd BufEnter * lua vim.opt.wrap = false
      autocmd FileType qf set nobuflisted
      autocmd vimenter * hi Comment term=bold cterm=NONE ctermfg=Darkgrey ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
    augroup end


    " augroup _packer
    "   autocmd!
    "   autocmd FileType lua lua print(<afile>)
    " augroup end
    "

    augroup _git
      autocmd!
      " autocmd FileType gitcommit setlocal wrap
      autocmd FileType gitcommit setlocal spell
    augroup end

    augroup _markdown
      autocmd!
      " autocmd FileType markdown setlocal wrap
      autocmd FileType markdown setlocal spell
    augroup end

    augroup _auto_resize
      autocmd!
      autocmd VimResized * tabdo wincmd = 
    augroup end

     " " Autoformat
     " augroup _lsp
     "   autocmd!
     "   autocmd BufWritePre * lua vim.lsp.buf.formatting()
     " augroup end
]]

-- ---------------------------------------------------------------------------
-- Spell configuration
-- ---------------------------------------------------------------------------

local function personal_spellfile()
    local repo_home = vim.env.AJLOW_REPO_HOME or (os.getenv("HOME") .. "/repos")
    return repo_home .. "/personal/ajlow2000_nixos/userspace/dotfiles/nvim/spell/en.utf-8.add"
end

local function ensure_spell_dir(path)
    local dir = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
end

local spell_augroup = vim.api.nvim_create_augroup("_spell", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = spell_augroup,
    pattern = { "gitcommit", "markdown" },
    callback = function()
        local spellfile = personal_spellfile()
        ensure_spell_dir(spellfile)
        vim.opt_local.spellfile = { spellfile }

        vim.keymap.set("n", "zg", function()
            vim.cmd("normal! zg")
            vim.fn.jobstart(
                { "sh", "-c", string.format(
                    "git add %s && git commit -m 'chore(nvim): add word to personal spellfile' && git push || true",
                    vim.fn.shellescape(spellfile)
                )},
                { cwd = vim.fn.fnamemodify(spellfile, ":h") }
            )
        end, { buffer = true, desc = "[Spell] Add word, commit, and push spellfile" })
    end,
    desc = "Set personal spellfile for spell-enabled filetypes",
})
