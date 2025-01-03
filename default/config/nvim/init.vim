"" ==============================================================================
"" EDITING & MOVING
"" ==============================================================================

" Search and highlight while typing while ignoring case when only lower case used
set ignorecase      " ignore case in search patterns
set smartcase       " use case-sensitive search if pattern contains upper case

" Activate spellchecker
set spell spelllang=en_us
set spellcapcheck=

" Use spaces for tabs
set tabstop=4       " how wide a Tab character is defined
set softtabstop=4   " how far cursor moves while typing Tab
set shiftwidth=4    " Number of spaces to use for each step of (auto)indent
set expandtab       " convert tab characters to spaces

" Fold using indentation
au FileType python set foldmethod=indent foldnestmax=1 foldminlines=10
" Open/close folds with space
au FileType python nnoremap <space> za

" Format json file with ctrl+m shortcut key
nnoremap <F2> :%!jq .<CR>

" Explicitly set the amount of indentation added automatically in python
" - lines after a parenthesis is open are indented only one more than
"   the parenthesis line (default is to add two indentations)
" https://neovim.io/doc/user/indent.html#ft-python-indent
" https://stackoverflow.com/questions/71974087/neovim-auto-indentation-nuances
let g:python_indent = {}
let g:python_indent.closed_paren_align_last_line = v:false
let g:python_indent.continue = 'shiftwidth()'
let g:python_indent.open_paren = 'shiftwidth()'

" Add vertical line
:set colorcolumn=120    " highlight column after 120 characters to 
:highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

" Disable mouse
set mouse=

" Setting for diffing (vi -d)
set diffopt+=iwhiteall  " ignore all whitespace differences

" Fuzzy CLI completion
set wildoptions+=fuzzy


"" ==============================================================================
"" PLUGINS
"" ==============================================================================

function! PackInit() abort
  packadd minpac

  call minpac#init()

  " Additional plugins here.
  call minpac#add('vimwiki/vimwiki')
  call minpac#add('dracula/vim', { 'name': 'dracula'})

  " Some configurations for the lsp language server
  call minpac#add('neovim/nvim-lspconfig')

endfunction

" Define user commands for updating/cleaning the plugins.
" Each of them calls PackInit() to load minpac and register
" the information of plugins, then performs the task.
command! PackUpdate call PackInit() | call minpac#update()
command! PackClean  call PackInit() | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()


" Plugin settings here
" ====================


" Colorscheme
" ===========

let g:dracula_colorterm = 0
colorscheme dracula


" Vimwiki
" =======

" Documentation: https://raw.githubusercontent.com/vimwiki/vimwiki/master/doc/vimwiki.txt

" Set default directory for wiki files
let g:vimwiki_list = [{'path': "$DWD/wiki"}]

" Specify different syntax for different file extensions
" Note that vimwiki uses the underlined syntax for markdown headers (https://github.github.com/gfm/)
" let g:vimwiki_ext2syntax = {'.wiki': 'media', '.md': 'markdown'}

" If you don't want markdown files to be handled by vimwiki:
let g:vimwiki_ext2syntax = {'.wiki': 'media'}

" Fold sections and code blocks
let g:vimwiki_folding = 'expr'

" Manually set colors for each heading level; default is all the same color
hi VimwikiHeader1 ctermfg=Green
hi VimwikiHeader2 ctermfg=Cyan
hi VimwikiHeader3 ctermfg=Blue
hi VimwikiHeader4 ctermfg=Yellow
hi VimwikiHeader5 ctermfg=Red
hi VimwikiHeader6 ctermfg=Brown



" Language Server Protocol
" ========================

" Specify Python 3 to use
" on personal computer:
" let g:python3_host_prog = '/home/alex/.venv/bin/python3'
" on work computer Ubuntu 20.04:
" let g:python3_host_prog = '/usr/bin/python3'
" on work computer:
let g:python3_host_prog = '/home/aortan/.venv/bin/python3'
" TODO: make it consistent across computers

"set omnifunc=syntaxcomplete#Complete

lua require("init")
