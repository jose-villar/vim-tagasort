" Tagasort - autoload file

function! tagasort#CharAt(index, str) abort
  if a:index < 0 || strchars(a:str) == 0 || a:index >= strchars(a:str)
    return -1
  endif
  return nr2char(strgetchar(a:str, a:index))
endfunction

function! tagasort#CursorDidMove() abort
  if getpos('.') != s:prevPos
    return 1
  else
    return 0
  endif
endfunction

function! tagasort#FoundValidClosingTag() abort
  let s:colNum = col('.')
  let s:line = getline('.')
  let ch = tagasort#CharAt(s:colNum - 1, s:line)
  let prevCh = tagasort#CharAt(s:colNum - 2, s:line)
  return( ch == '>' && prevCh != '=' )
endfunction

function! tagasort#FindNextClosingTag() abort
  let s:line = getline('.')

  while ! tagasort#FoundValidClosingTag()
    let s:prevPos = getpos('.')
    normal! f>
    if ! tagasort#CursorDidMove()
      return [-1, -1, -1, -1]
    endif
  endwhile

  return getpos('.')
endfunction

" Returns the tag found where the cursor is located, and its position in the
" current line
function! tagasort#GetCurrentTag() abort
  let endIndex = tagasort#FindNextClosingTag()[2]
  if endIndex == -1 | return | endif

  let s:prevPos = getpos('.')
  normal! F<
  if ! tagasort#CursorDidMove() | return | endif

  let startIndex = col('.')
  let s:content = s:line[startIndex - 1 : endIndex - 1]

  call setpos('.', s:originalPos)
  return [s:content, startIndex - 1, endIndex]
endfunction

function! tagasort#SortTag() abort
  let tagAsList = split(s:content, ' ')
  let openTag = remove(tagAsList, 0)
  let closeTag = remove(tagAsList, len(tagAsList) - 1)
  call sort(tagAsList)
  call add(tagAsList, closeTag)
  call insert(tagAsList, openTag, 0)
  let s:content = join(tagAsList)
endfunction

function! tagasort#PreFormatTagForSorting()
  execute 'normal! o'.s:content
  " Remove duplicated whitespaces
  .sno/ \s\+/ /ge
  " Mark whitespaces within quotation marks
  .sm/"[^"]*"/\=substitute(submatch(0), ' ', s:auxString, 'g')/ge
  .sm/\'[^\']*\'/\=substitute(submatch(0), ' ', s:auxString, 'g')/ge
  .sno/>/ >/ge  " > =>  >
  .sno/\/ >/\/>/ge " / > => />
  .sno/\/>/ \/>/ge " /> =>  />
  .sno/\s\+=/=/ge "     = => =
  .sno/=\s\+/=/ge " =     => =
  .sno/{ /{/ge " {  => {
  .sno/ }/}/ge "  } => }
  .sno/\s\+,/,/ge "    , => ,
  .sno/,\s+/,/ge " ,    => ,
  .sno/= >/=>/ge " = > => =>
  .sno/=> /=>/ge " =>  => =>
  .sno/ =>/=>/ge "  => => =>
  .sno/( /(/ge " (\s => (
  .sno/ )/)/ge " \s) => )
  execute 'normal! 0d$'
  let s:content = @"
  execute 'normal! dd'
  call setpos('.', s:originalPos)
endfunction

function! tagasort#PostFormatTag()
  execute 'normal! o'.s:content
  " Restore withspaces within quotation marks
  execute '.sno/' . s:auxString . '/ /ge'
  .sno/{/{ /ge " { => {\s
  .sno/}/ }/ge " } => \s}
  .sno/\s\+,/,/ge "    , => ,
  .sno/,/, /ge " , => ,\s
  .sno/=>/ => /ge " => => \s=>\s
  .sno/{ {/{{/ge " { { => {{
  .sno/} }/}}/ge " } } => }}
  .sno/(/( /ge " ( => (\s
  .sno/)/ )/ge " ) => \s)
  .sno/ \s\+/ /ge " Remove duplicated whitespaces
  .sno/( )/()/ge " ( ) => ()
  .sno/\s>/>/ge " \s> => >

  execute 'normal! 0d$'
  let s:content = @"
  execute 'normal! dd'

  call setpos('.', s:originalPos)
endfunction

function! tagasort#CleanUpVars()
  unlet s:colNum
  unlet s:line
  unlet s:prevPos
  unlet s:originalPos
  unlet s:originalPosLineNumber
  unlet s:originalPosColNumber
  unlet s:currentPos
  unlet s:content
  unlet s:auxString
endfunction

function! tagasort#FormatTag() abort
  "Aux String is used for marking whitespaces within quotation marks
  let s:auxString = "|$|$|...tagasort...|$|$|"
  let s:colNum = col('.')
  let s:line = getline('.')
  let s:prevPos = getpos('.')
  let s:originalPos = getpos('.')
  let s:originalPosLineNumber = line('.')
  let s:originalPosColNumber = col('.')
  let s:currentPos = getpos('.')
  let savedReg = @"
  let savedRegType = getregtype('')
  let ans = tagasort#GetCurrentTag()

  if empty(ans) || strchars(ans[0]) < 3 | return | endif

  let s:content = ans[0]
  let startIndex = ans[1]
  let endIndex = ans[2]
  let firstPart = strcharpart(s:line, 0, startIndex)
  let lastPart = strcharpart(s:line, endIndex, len(s:line) - 1)

  call tagasort#PreFormatTagForSorting()
  call tagasort#SortTag()
  call tagasort#PostFormatTag()

  let s:content = trim(s:content)
  let finalResult = firstPart.s:content.lastPart

  call setline('.', finalResult)
  normal! ==
  call setpos('.', s:originalPos)
  call setreg('', savedReg, savedRegType)

  call tagasort#CleanUpVars()
endfunction
