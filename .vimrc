"
" ~/.vimrc
"

" Set clipboard
" Arch's vim package comes without clipboard support, so no point setting it.
"setg clipboard=unnamed

" Mouse and backspace
setg mouse=
setg bs=2

" Rebind <leader> key
let mapleader=","

" Disable arrow keys in escape more
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
" Disable arrow keys in insert more
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

" Code block indentation
vnoremap < <gv
vnoremap > >gv

" Show whitespace
" MUST be inserted BEFORE the colorscheme command
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

" Color scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
color wombat256mod
set t_Co=256

" Enable syntax highlighting
filetype off
filetype plugin on
filetype indent off
syntax on

" Showing line numbers and length
highlight ColorColumn ctermbg=darkgrey
set breakindent
set breakindentopt=sbr
set colorcolumn=80
set linebreak
set number
set ruler
set showbreak=>>>
set nowrap

" Tabs and spaces
set noexpandtab
set shiftwidth=4
set softtabstop=0
set tabstop=4

" Make search case insensitive
set hlsearch
set ignorecase
set incsearch
set smartcase
highlight Search cterm=none ctermbg=grey ctermfg=black

" Disable backup and swap files
set nobackup
set nowritebackup
set noswapfile

" Auto match pairs
inoremap (<CR> (<CR>)<esc>O
inoremap (;<CR> (<CR>);<esc>O
inoremap [<CR> [<CR>]<esc>O
inoremap [;<CR> [<CR>];<esc>O
inoremap {<CR> {<CR>}<esc>O
inoremap {;<CR> {<CR>};<esc>O

" Settings for ctrlp
" https://github.com/ctrlpvim/ctrlp.vim
" community/vim-ctrlp
let g:ctrlp_max_height=15
" set wildignore+=*.pyc
" set wildignore+=*_build/*
" set wildignore+=*/coverage/*
let g:ctrlp_working_path_mode=""

" Settings for jedi-vim
" https://github.com/davidhalter/jedi-vim
" community/vim-jedi
" let g:jedi#usages_command="<leader>z"
" let g:jedi#popup_on_dot=0
" let g:jedi#popup_select_first=1
"" map <Leader>b Oimport ipdb; ipdb.set_trace() # BREAKPOINT<C-c>
" let g:jedi#show_call_signatures="0"
" let g:jedi#use_splits_not_buffers="right"

" Settings for gitgutter
" https://github.com/airblade/vim-gitgutter
let g:gitgutter_map_keys=1
let g:gitgutter_realtime=1
let g:gitgutter_eager=1

" Settings for nerdcommenter
" https://github.com/scrooloose/nerdcommenter
" community/vim-nerdcommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims=1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs=0
" Align line-wise comment delimiters flush left instead of following code
" indentation
let g:NERDDefaultAlign="left"
" Set a language to use its alternate delimiters by default
"let g:NERDAltDelims_java=1
" Add your own custom formats or override the defaults
"let g:NERDCustomDelimiters={ "c": { "left": "/**","right": "*/" } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines=1
" Enable trimming of trailing whitespace when uncommenting
"let g:NERDTrimTrailingWhitespace=1
" For some reason Vim / terminal sees <C-/> as <C-_> .
nmap <C-_> <leader>c<space>

" Settings for omnicomplete
" community/vim-omnicppcomplete
" For some reason Vim / terminal sees <C-space> as <C-@> .
" inoremap <C-@> <C-x><C-o>

" Set file encoding
set encoding=utf-8

" Under-powered laptop seems to scroll the files better when scrolling a long
" way.
set lazyredraw

" Spellcheck
set spell
highlight SpellBad cterm=underline ctermbg=none ctermfg=red

" Show cursor line and split panes below and to the right
set cursorline
set splitbelow
set splitright

" Settings for airline
" https://github.com/vim-airline/vim-airline
" community/vim-airline
set laststatus=2
let g:airline#extensions#tabline#enabled=1

" Language specific settings
autocmd FileType php setl colorcolumn=120
autocmd FileType python setl colorcolumn=80
autocmd FileType php setl expandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType python setl expandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType php,python setl autoindent indentexpr&
autocmd FileType php,python setl foldmethod=indent foldnestmax=2
autocmd FileType php,python setl list listchars=tab:┊\ ,trail:·,eol:↲,extends:>,precedes:<

