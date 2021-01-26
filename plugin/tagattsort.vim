" Tagattsort - Tags' attributes sorter
" Author:  José Villar
" Version: 0.1
" ------------------------------------------------------------------------------

" Exit when app has already been loaded, or "compatible" mode is set, or vim
" version is lower than 700
if exists("g:loaded_Tagattsort") || &cp || v:version < 700
  finish
endif

let g:loaded_Tagattsort = 1
let s:keepcpo           = &cpo
set cpo&vim

if !hasmapto('<Plug>TagattsortNMode')
  nmap <unique><Space><Space> <Plug>TagattsortNMode
endif

noremap <silent> <unique> <script> <Plug>TagattsortNMode
 \ :set lz<CR>:call <SID>FormatTagNMode()<CR>:set nolz<CR>

" ------------------------------------------------------------------------------

function! s:CharAt(index, str) abort
  if a:index < 0 || strchars(a:str) == 0 || a:index >= strchars(a:str)
    return -1
  endif
  return nr2char(strgetchar(a:str, a:index))
endfunction

function! s:FindNextClosingTag() abort
  let s:pos = getpos('.')
  let s:line = getline('.')
  let s:ch = s:CharAt(s:pos[2] - 1, s:line)
  let s:prevCh = s:CharAt(s:pos[2] - 2, s:line)
  let s:prevPos = getpos('.')

  while( s:ch != '>' )
    normal! f>
    if getpos('.') == s:prevPos
      return [-1,-1,-1,-1]
    endif
    let s:pos = getpos('.')
    let s:ch = s:CharAt(s:pos[2] - 1, s:line)
    let s:prevCh = s:CharAt(s:pos[2] - 2, s:line)
    while (s:prevCh == '=')
      normal! f>
      if getpos('.') == s:pos
        return [-1,-1,-1,-1]
      endif
      let s:pos = getpos('.')
      let s:ch = s:CharAt(s:pos[2] - 1, s:line)
      let s:prevCh = s:CharAt(s:pos[2] - 2, s:line)
      let s:prevpos = getpos('.')
    endwhile
    let s:prevpos = getpos('.')
  endwhile

  if s:line != getline('.')
    return [-1,-1,-1,-1]
  endif

  return getpos('.')
endfunction

" Returns the tag found where the cursor is located, and its position in the
" current line
function! s:GetCurrentTag() abort
  let s:line = getline('.')
  let s:originalPos = getpos('.')
  let s:originalPosLineNumber = s:originalPos[1]
  let s:originalPosColNumber = s:originalPos[2]
  let s:charAtCursor = s:CharAt(s:originalPosColNumber - 1, s:line)

  if s:charAtCursor == '<'
    let s:startIndex = s:originalPosColNumber
    let s:endIndex = s:FindNextClosingTag()[2]
    if s:endIndex == -1
      return
    endif
  elseif s:charAtCursor == '>'
    let s:endIndex = s:originalPosColNumber
    normal! F<
    if s:CharAt(getpos('.')[2] - 1, getline('.')) == '>'
      return
    else
      let s:startIndex = getpos('.')[2]
    endif

    if s:endIndex != s:FindNextClosingTag()[2]
      return
    endif

  else
    let s:endIndex = s:FindNextClosingTag()[2]

    if s:endIndex == -1
      return
    endif
    normal! F<
    let s:startIndex = getpos('.')[2]

    if s:endIndex == s:startIndex
      return
    endif

  endif

  if s:line != getline('.')
    return
  endif

  let s:tag = s:line[s:startIndex - 1 : s:endIndex - 1]
  return [s:tag, s:startIndex - 1, s:endIndex]
  unlet s:line
  unlet s:originalPos
  unlet s:originalPosLineNumber
  unlet s:originalPosColNumber
  unlet s:charAtCursor
  unlet s:startIndex
  unlet s:endIndex
  unlet s:tag
endfunction

function! s:SortTag(tag) abort
  let s:tagAsList = split(a:tag, ' ')
  let s:openTag = remove(s:tagAsList, 0)
  let s:closeTag = remove(s:tagAsList, len(s:tagAsList) - 1)
  call sort(s:tagAsList)
  call add(s:tagAsList, s:closeTag)
  call insert(s:tagAsList, s:openTag, 0)
  return join(s:tagAsList)
  unlet s:tagAsList
  unlet s:openTag
  unlet s:closeTag
endfunction

function! s:FormatTagNMode() abort
  let s:savedPos = getpos(".")
  let s:line = getline('.')
  let s:res = s:GetCurrentTag()
  call setpos('.', s:savedPos)

  if empty(s:res)
    return
  endif

  let s:tag=s:res[0]
  if strchars(s:tag) < 3
    return
  endif

  let s:startIndex=s:res[1]
  let s:endIndex=s:res[2]
  let s:originalTag = s:res[0]

  let s:firstPart = strcharpart(s:line, 0, s:startIndex)
  let s:secondPart = strcharpart(s:line, s:endIndex, len(s:line) - 1)

  call setpos('.', s:savedPos)

  execute 'normal! o'.s:tag
  .s/ \s\+/ /ge
  .s/>/ >/ge
  .s/\/ >/\/>/ge
  .s/\/>/ \/>/ge
  .s/\s\+=/=/ge
  .s/=\s\+/=/ge
  let s:savedReg=@"
  let s:savedRegType = getregtype('')

  execute 'normal! 0"0d$'
  let s:tag=@"
  execute 'normal! dd'
  call setreg('', s:savedReg, s:savedRegType)

  "Shrink Curly Braces
  let s:tag = substitute(s:tag, "{ ", "{", "ge")
  let s:tag = substitute(s:tag, " }", "}", "ge")
  let s:tag = substitute(s:tag, "\s\+,", ",", "ge")
  let s:tag = substitute(s:tag, ", ", ",", "ge")
  let s:tag = substitute(s:tag, "= >", "=>", "ge")
  let s:tag = substitute(s:tag, "=> ", "=>", "ge")
  let s:tag = substitute(s:tag, " =>", "=>", "ge")

  let s:tag = substitute(s:tag, "/ >", "/>", "ge")
  let s:tag = substitute(s:tag, "/  >", "/>", "ge")
  let s:tag = substitute(s:tag, "/>", " />", "ge")

  let s:tag = substitute(s:tag, " \s\+", " ", "ge")
  let s:tag = substitute(s:tag, "\s\+=", "=", "ge")
  let s:tag = substitute(s:tag, "=\s\+", "=", "ge")

  call setpos('.', s:savedPos)
  let s:tag = s:SortTag(s:tag)

  "Expand curly braces
  let s:tag = substitute(s:tag, "{", "{ ", "ge")
  let s:tag = substitute(s:tag, "}", " }", "ge")
  let s:tag = substitute(s:tag, "\s\+,", ",", "ge")
  let s:tag = substitute(s:tag, ",", ", ", "ge")
  let s:tag = substitute(s:tag, "=>", " => ", "ge")
  let s:tag = substitute(s:tag, "{ {", "{{", "ge")
  let s:tag = substitute(s:tag, "} }", "}}", "ge")
  let s:tag = trim(s:tag)

  let s:finalResult = s:firstPart.s:tag.s:secondPart
  let s:finalResult = substitute(s:finalResult, "><", "> <", "ge")

  call setline('.', s:finalResult)
  call setpos('.', s:savedPos)
  .s/ \s\+/ /ge
  normal!==
  call setpos('.', s:savedPos)
  unlet s:tag
  unlet s:finalResult
  unlet s:savedPos
  unlet s:res
  unlet s:firstPart
  unlet s:secondPart
  unlet s:startIndex
  unlet s:endIndex
  unlet s:line
  unlet s:originalTag
endfunction

"" ------------------------------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo



