" Tagasort - Tags attributes sorter
" Vim plugin for sorting and formatting the attributes of html and jsx tags
" Maintainer:  José Villar
" Last Change: 2021 Feb 2
" Version: 0.3
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
 \ :set lz<CR>:call <SID>FormatTag()<CR>:set nolz<CR>

" ------------------------------------------------------------------------------

function! s:CharAt(index, str) abort
  if a:index < 0 || strchars(a:str) == 0 || a:index >= strchars(a:str)
    return -1
  endif
  return nr2char(strgetchar(a:str, a:index))
endfunction

function! s:CursorDidMove() abort
  if getpos('.') != s:prevPos
    return 1
  else
    return 0
  endif
endfunction

function! s:FoundValidClosingTag() abort
  let s:colNum = col('.')
  let s:line = getline('.')
  let ch = s:CharAt(s:colNum - 1, s:line)
  let prevCh = s:CharAt(s:colNum - 2, s:line)
  return( ch == '>' && prevCh != '=' )
endfunction

function! s:FindNextClosingTag() abort
  let s:line = getline('.')

  while ! s:FoundValidClosingTag()
    let s:prevPos = getpos('.')
    normal! f>
    if ! s:CursorDidMove()
      return [-1, -1, -1, -1]
    endif
  endwhile

  return getpos('.')
endfunction

" Returns the tag found where the cursor is located, and its position in the
" current line
function! s:GetCurrentTag() abort
  let endIndex = s:FindNextClosingTag()[2]
  if endIndex == -1 | return | endif

  let s:prevPos = getpos('.')
  normal! F<
  if ! s:CursorDidMove() | return | endif

  let startIndex = col('.')
  let s:content = s:line[startIndex - 1 : endIndex - 1]

  call setpos('.', s:originalPos)
  return [s:content, startIndex - 1, endIndex]
endfunction

function! s:SortTag() abort
  let tagAsList = split(s:content, ' ')
  let openTag = remove(tagAsList, 0)
  let closeTag = remove(tagAsList, len(tagAsList) - 1)
  call sort(tagAsList)
  call add(tagAsList, closeTag)
  call insert(tagAsList, openTag, 0)
  return join(tagAsList)
endfunction

function! s:PreFormatTagForSorting()
  execute 'normal! o'.s:content
  .s/\V \s\+/ /ge " Remove duplicated whitespaces
  .s/\V>/ >/ge  " > =>  >
  .s/\V\/ >/\/>/ge " / > => />
  .s/\V\/>/ \/>/ge " /> =>  />
  .s/\V\s\+=/=/ge "     = => =
  .s/\V=\s\+/=/ge " =     => =
  .s/\V{ /{/ge " {  => {
  .s/\V }/}/ge "  } => }
  .s/\V\s\+,/,/ge "    , => ,
  .s/\V,\s+/,/ge " ,    => ,
  .s/\V= >/=>/ge " = > => =>
  .s/\V=> /=>/ge " =>  => =>
  .s/\V =>/=>/ge "  => => =>
  .s/\V( /(/ge " (\s => (
  .s/\V )/)/ge " \s) => )
  execute 'normal! 0d$'
  let s:content = @"
  execute 'normal! dd'
  call setpos('.', s:originalPos)
endfunction

function! s:PostFormatTag()
  execute 'normal! o'.s:content

  .s/\V{/{ /ge " { => {\s
  .s/\V}/ }/ge " } => \s}
  .s/\V\s\+,/,/ge "    , => ,
  .s/\V,/, /ge " , => ,\s
  .s/\V=>/ => /ge " => => \s=>\s
  .s/\V{ {/{{/ge " { { => {{
  .s/\V} }/}}/ge " } } => }}
  .s/\V(/( /ge " ( => (\s
  .s/\V)/ )/ge " ) => \s)
  .s/\V \s\+/ /ge " Remove duplicated whitespaces
  .s/\V( )/()/ge " ( ) => ()
  .s/\V\s>/>/ge " \s> => >

  execute 'normal! 0d$'
  let s:content = @"
  execute 'normal! dd'

  call setpos('.', s:originalPos)
endfunction

function! s:CleanUpVars()
  unlet s:colNum
  unlet s:line
  unlet s:prevPos
  unlet s:originalPos
  unlet s:originalPosLineNumber
  unlet s:originalPosColNumber
  unlet s:currentPos
  unlet s:content
endfunction

function! s:FormatTag() abort
  let s:colNum = col('.')
  let s:line = getline('.')
  let s:prevPos = getpos('.')
  let s:originalPos = getpos('.')
  let s:originalPosLineNumber = line('.')
  let s:originalPosColNumber = col('.')
  let s:currentPos = getpos('.')
  let savedReg = @"
  let savedRegType = getregtype('')
  let ans = s:GetCurrentTag()

  if empty(ans) || strchars(ans[0]) < 3 | return | endif

  let s:content = ans[0]
  let startIndex = ans[1]
  let endIndex = ans[2]
  let firstPart = strcharpart(s:line, 0, startIndex)
  let lastPart = strcharpart(s:line, endIndex, len(s:line) - 1)

  call s:PreFormatTagForSorting()
  call s:SortTag()
  call s:PostFormatTag()

  let s:content = trim(s:content)
  let finalResult = firstPart.s:content.lastPart

  call setline('.', finalResult)
  normal! ==
  call setpos('.', s:originalPos)
  call setreg('', savedReg, savedRegType)

  call s:CleanUpVars()
endfunction

"" ------------------------------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo
