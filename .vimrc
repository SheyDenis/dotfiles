"
" ~/.vimrc
"

" Vundle setup
" https://github.com/VundleVim/Vundle.vim
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Bundle 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
Plugin 'alvan/vim-closetag'
Plugin 'chiel92/vim-autoformat'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'gregsexton/matchtag'
Plugin 'junegunn/vim-easy-align'
Plugin 'michalbachowski/vim-wombat256mod'
Plugin 'nvie/vim-flake8'
Plugin 'posva/vim-vue'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'yggdroot/indentline'

call vundle#end()
filetype plugin indent on

" Set clipboard
" Arch's vim package comes without clipboard support, so no point setting it.
"setg clipboard=unnamed

" Mouse and backspace
setg mouse=
setg bs=2

" Rebind <leader> key
let mapleader=','

" Disable arrow keys in escape mode
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
" Disable arrow keys in insert mode
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>
" Bindings for tab switching
nnoremap <leader>h <esc>:tabprevious<CR>
nnoremap <leader>j <esc>:tabclose<CR>
nnoremap <leader>k <esc>:tabnew<CR>
nnoremap <leader>l <esc>:tabnext<CR>
" Bindings for splits switching
noremap <C-h> <C-w><C-h>
noremap <C-j> <C-w><C-j>
noremap <C-k> <C-w><C-k>
noremap <C-l> <C-w><C-l>

" This is unnecessary
inoremap <C-@> <NOP>

" Enable folding with the spacebar
nnoremap <space> za

" Show whitespace
" MUST be inserted BEFORE the colorscheme command
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

" Color scheme
" https://github.com/michalbachowski/vim-wombat256mod
color wombat256mod
set t_Co=256

" UI
syntax on
highlight ColorColumn ctermbg=darkgrey
highlight SpellBad cterm=underline ctermbg=none ctermfg=red
set breakindent
set breakindentopt=sbr
set colorcolumn=80
set cursorline
set lazyredraw
set linebreak
set nowrap
set number
set ruler
set showbreak=>>>
set spell
set splitbelow
set splitright
set wildmenu

" Tabs and spaces
set noexpandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
vnoremap < <gv
vnoremap > >gv

" Search
highlight Search cterm=none ctermbg=grey ctermfg=black
set hlsearch
set ignorecase
set incsearch
set smartcase

" Misc
set encoding=utf-8

" Backup and Swap
set nobackup
set nowritebackup
set swapfile
set dir=~/.vim/swap//

" Auto match pairs
inoremap (<CR> (<CR>)<esc>O
inoremap (;<CR> (<CR>);<esc>O
inoremap [<CR> [<CR>]<esc>O
inoremap [;<CR> [<CR>];<esc>O
inoremap {<CR> {<CR>}<esc>O
inoremap {;<CR> {<CR>};<esc>O

" Settings for ctrlp
" https://github.com/ctrlpvim/ctrlp.vim
let g:ctrlp_max_height=15
let g:ctrlp_working_path_mode=0
set wildignore+=*/node_modules/*
set wildignore+=*.pyc

" Settings for gitgutter
" https://github.com/airblade/vim-gitgutter
let g:gitgutter_eager=1
let g:gitgutter_map_keys=1
let g:gitgutter_realtime=1

" Settings for nerdcommenter
" https://github.com/scrooloose/nerdcommenter
let g:NERDCommentEmptyLines=1
let g:NERDCompactSexyComs=0
let g:NERDDefaultAlign='left'
let g:NERDSpaceDelims=1
" For some reason Vim / terminal sees <C-/> as <C-_> .
nmap <C-_> <leader>c<space>

" Settings for vim-flake8
" https://github.com/nvie/vim-flake8
autocmd BufWritePost *.py call Flake8()
let g:flake8_show_in_gutter=1

" Settings for SimplyFold
" https://github.com/tmhedberg/SimpylFold
let g:SimpylFold_docstring_preview=1

" Settings for YouCompleteMe
" https://github.com/Valloric/YouCompleteMe
let g:ycm_autoclose_preview_window_after_completion=1

" Settings for airline
" https://github.com/vim-airline/vim-airline
let g:airline#extensions#tabline#enabled=1
set laststatus=2

" Settings for vim-closetag
" https://github.com/alvan/vim-closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.vue'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.html,*.vue'

" Language specific settings
" HTML
autocmd FileType html setl autoindent
autocmd FileType html setl colorcolumn=120 textwidth=119
autocmd FileType html setl expandtab shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType html setl foldmethod=indent foldnestmax=2
autocmd FileType html setl list listchars=tab:┊\ ,trail:·,eol:↲,extends:>,precedes:<
" Javascript
autocmd FileType javascript setl autoindent
autocmd FileType javascript setl colorcolumn=120 textwidth=119
autocmd FileType javascript setl expandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType javascript setl foldmethod=indent foldnestmax=2
autocmd FileType javascript setl list listchars=tab:┊\ ,trail:·,eol:↲,extends:>,precedes:<
" PHP
autocmd FileType php setl autoindent
autocmd FileType php setl colorcolumn=120 textwidth=119
autocmd FileType php setl expandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType php setl foldmethod=indent foldnestmax=2
autocmd FileType php setl list listchars=tab:┊\ ,trail:·,eol:↲,extends:>,precedes:<
" Python
autocmd FileType python setl autoindent
autocmd FileType python setl colorcolumn=80 textwidth=79
autocmd FileType python setl expandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType python setl foldmethod=indent foldnestmax=2
autocmd FileType python setl list listchars=tab:┊\ ,trail:·,eol:↲,extends:>,precedes:<
"python with virtualenv support
py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF
" Vue.js
autocmd FileType vue setl autoindent
autocmd FileType vue setl colorcolumn=120 textwidth=119
autocmd FileType vue setl expandtab shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType vue setl foldmethod=indent foldnestmax=2
autocmd FileType vue setl list listchars=tab:┊\ ,trail:·,eol:↲,extends:>,precedes:<
" yaml
autocmd FileType yaml setl autoindent
autocmd FileType yaml setl colorcolumn=120 textwidth=119
autocmd FileType yaml setl expandtab shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType yaml setl foldmethod=indent foldnestmax=2
autocmd FileType yaml setl list listchars=tab:┊\ ,trail:·,eol:↲,extends:>,precedes:<

