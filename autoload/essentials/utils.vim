" {{{ Global Functions
" Return foldexpr for the current line. If current line begins with Q[1-99]
" the returned expression will fold with this level starts at this line else
" it will use the fold level of the previous line
function! essentials#utils#stackoverflow_fold_expr()
	let thisline = getline(v:lnum)
	if match(thisline, '^Q\d\{1,2\}\.') >= 0
		return ">1"
	else
		return "="
	endif
endfunction

" Warn user of a message with a popup
function! essentials#utils#warn(message) abort
  echohl WarningMsg
  echo "vim-essentials: " . a:message
  echohl None
  let v:warningmsg = a:message
endfunction

function! essentials#utils#get_visual_select()
    " getpos returns [bufnum, lnum, col, off]
    " Here it gets elements indexed at 1 and 2 and assign them
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]

    " Get line from start to the end of the selection
    let lines = getline(line_start, line_end)

    " It should not be empty but if that happens we return empty
    if len(lines) == 0 | return ''|  endif

    " If selection is inclusive that means last character is included.
    " Here we first set lastline's index offset to be 1, then add 1
    " for non-inclusive selections like exclusive
    let column_end_offset = &selection == 'inclusive' ? 1 : 2
    " Set lastline with index offset applied so we get correct text
    let lines[-1] = lines[-1][: column_end - column_end_offset]
    " Set firstline to start with first character with 1 index offset.
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, " ")
endfunction
" }}}
