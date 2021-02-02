" Tagasort - Tags attributes sorter
" Vim plugin for sorting and formatting the attributes of html and jsx tags
" Maintainer:  José Villar
" Last Change: 2021 Feb 2
" Version: 0.4
" ------------------------------------------------------------------------------

" Exit when app has already been loaded, or "compatible" mode is set, or vim
" version is lower than 700
if exists("g:loaded_tagasort") || &cp || v:version < 700
  finish
endif

let g:loaded_tagasort = 1
let s:keepcpo = &cpo
set cpo&vim

if !hasmapto('<Plug>Tagasort_FormatTag')
  nmap <unique><Space><Space> <Plug>Tagasort_FormatTag
endif

noremap <silent> <unique> <script> <Plug>Tagasort_FormatTag
 \ :set lz<CR>:call tagasort#FormatTag()<CR>:set nolz<CR>

"" ------------------------------------------------------------------------------
let &cpo = s:keepcpo
unlet s:keepcpo
