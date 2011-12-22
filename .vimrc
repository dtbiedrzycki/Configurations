" map <C-J> gqap
" imap <C-J> <ESC>gqapi
syntax enable
set title

" Make trailing whitespace visible
" set list listchars=eol:\ ,tab:>-,trail:.,extends:>,nbsp:_

syntax spell toplevel

filetype indent on
filetype plugin on
set grepprg=grep\ -nH\ $*

" Auto number... 
set nu

set modeline

" Fast buffer switching
map <C-N> <Esc>:bn<CR>
map <C-P> <Esc>:bp<CR>

" autoindent is evil
set noai

set tabstop=3
set shiftwidth=3
set expandtab
set showmatch
set tw=78
set nocompatible

" Makes buffers not need to be saved when hidden.  Use with care.
set hidden
" set visualbell
" set digraph

" Spelling
highlight SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse

" Test the autocommand
" autocmd BufReadPost,FileReadPost    *.java read ~/c.txt

highlight Comment ctermfg=LightGray

filetype plugin indent on
syntax on

" stop the search from being obnoxious and hilighting everything
set nohlsearch

" change comment color
highlight Comment ctermfg=darkcyan

set cursorline

