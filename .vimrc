"
" ~/.vimrc
"

" Set clipboard
set clipboard=unnamed

" Mouse and backspace
set mouse=a
set bs=2	" Make backspace normal

" Rebind <leader> key
let mapleader = ","

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
noremap <C-h> <esc>:tabprevious<CR>
noremap <C-k> <esc>:tabnew<CR>
noremap <C-l> <esc>:tabnext<CR>
" Bindings for splits switching
nnoremap <leader>h <C-w><C-h>
nnoremap <leader>j <C-w><C-j>
nnoremap <leader>k <C-w><C-k>
nnoremap <leader>l <C-w><C-l>

" Code block indentation
vnoremap < <gv
vnoremap > >gv

" Show whitespace
" MUST be inserted BEFORE the colorscheme command
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
au InsertLeave * match ExtraWhitespace /\s\+$/

" Color scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
color wombat256mod
set t_Co=256

" Enable syntax highlighting
filetype off
filetype plugin indent on
syntax on

" Showing line numbers and length
highlight ColorColumn ctermbg=233
"highlight ColorColumn ctermbg=gray ctermfg=red guibg=gray guifg=red
set breakindent
set breakindentopt=sbr
set colorcolumn=80
set linebreak
set number
set ruler
set showbreak=>>>
set wrap

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

" Disable backup and swap files
set nobackup
set nowritebackup
set noswapfile

" Settings for ctrlp
" https://github.com/kien/ctrlp.vim
" community/vim-ctrlp
let g:ctrlp_max_height = 10
"" set wildignore+=*.pyc
"" set wildignore+=*_build/*
"" set wildignore+=*/coverage/*

" Settings for jedi-vim
" https://github.com/davidhalter/jedi-vim
" community/vim-jedi
let g:jedi#usages_command="<leader>z"
let g:jedi#popup_on_dot=1
let g:jedi#popup_select_first=1
"" map <Leader>b Oimport ipdb; ipdb.set_trace() # BREAKPOINT<C-c>
let g:jedi#show_call_signatures="1"

" Settings for gitgutter
" https://github.com/airblade/vim-gitgutter
let g:gitgutter_map_keys=0
let g:gitgutter_realtime=1
let g:gitgutter_eager=1

" Settings for nerdcommenter
" https://github.com/scrooloose/nerdcommenter
" community/vim-nerdcommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims=1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs=0
" Align line-wise comment delimiters flush left instead of following code indentation
"let g:NERDDefaultAlign='left'
" Set a language to use its alternate delimiters by default
"let g:NERDAltDelims_java=1
" Add your own custom formats or override the defaults
"let g:NERDCustomDelimiters={ 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines=1
" Enable trimming of trailing whitespace when uncommenting
"let g:NERDTrimTrailingWhitespace=1

" Settings for omnicomplete
" community/vim-omnicppcomplete
" Better navigating through omnicomplete option list
" See http://stackoverflow.com/questions/2170023/how-to-map-keys-for-popup-menu-in-vim
"set completeopt=longest,menuone
function! OmniPopup(action)
	if pumvisible()
		if a:action == 'j'
			return "\<C-N>"
		elseif a:action == 'k'
			return "\<C-P>"
		endif
	endif
	return a:action
endfunction
inoremap <silent>j <C-R>=OmniPopup('j')<CR>
inoremap <silent>k <C-R>=OmniPopup('k')<CR>

" Misc
set encoding=utf-8
"set lazyredraw
set spell

" Show cursor line and split panes below and to the right
set cursorline
set splitbelow
set splitright

