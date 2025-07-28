-- TODO - rewrite in lua
vim.cmd [[
    augroup _general_settings
      autocmd!
      autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR> 
      autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 40}) 
      autocmd BufWinEnter * lua vim.opt.formatoptions:remove({"c", "o"})
      autocmd BufEnter * lua vim.opt.wrap = false
      autocmd FileType qf set nobuflisted
      autocmd vimenter * hi Comment term=bold cterm=NONE ctermfg=Darkgrey ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
    augroup end

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
]]
