call plug#begin(stdpath('config') . '/plugged')

Plug 'flazz/vim-colorschemes'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neovim/nvim-lspconfig'

call plug#end()

let mapleader=";"

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fd <cmd>Telescope file_browser<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>

" navigate split screens easily
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-k> :wincmd k<CR>

set relativenumber
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set guicursor=
set colorcolumn=120
set incsearch
set termguicolors
colorscheme molokai

lua << EOF
require('telescope').setup {
	defaults = {
		layout_strategy = "vertical",
		layout_config = {
			vertical = {
				mirror = true
				
			}
		}
	}
}
require'lspconfig'.pyright.setup{}
EOF
