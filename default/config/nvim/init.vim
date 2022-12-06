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

" Add vertical line
:set colorcolumn=120    " highlight column after 120 characters to 
:highlight ColorColumn ctermbg=lightgrey guibg=lightgrey


"" ==============================================================================
"" PLUGINS
"" ==============================================================================

function! PackInit() abort
  packadd minpac

  call minpac#init()

  " Additional plugins here.
  call minpac#add('vimwiki/vimwiki')
  call minpac#add('dracula/vim', { 'name': 'dracula'})

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


" Manually set colors for each heading level; default is all the same color
hi VimwikiHeader1 ctermfg=Green
hi VimwikiHeader2 ctermfg=Cyan
hi VimwikiHeader3 ctermfg=Blue
hi VimwikiHeader4 ctermfg=Yellow
hi VimwikiHeader5 ctermfg=Red
hi VimwikiHeader6 ctermfg=Brown

