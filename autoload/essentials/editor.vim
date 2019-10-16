" {{{ Plugin init
" Ensure filetypes set if user didn't configure ignore filetypes
if !exists('g:essentials_remove_whitespace_ignore_filetypes')
    let g:essentials_remove_whitespace_ignore_filetypes = []
endif

" Define custom whitespace character group to include all horizontal
" Unicode whitespace characters except tab (\u0009). Vim's '\s' class
" only includes ASCII spaces and tabs.
let s:whitespace_chars='\u0020\u00a0\u1680\u180e\u2000-\u200b\u202f\u205f\u3000\ufeff'
let s:eol_whitespace_pattern = '[\u0009' . s:whitespace_chars . ']\+'
" }}}

" {{{ script functions
" Checks if whitespace is in the global variable and if it is
" return false so it we won't match it against syntax highlight.
" This check is necessary because ft is subject to change at runtime
function! s:shouldMatchWhitespace()
    for ft in g:essentials_remove_whitespace_ignore_filetypes
        if ft ==# &filetype | return 0 | endif
    endfor
    return 1
endfunction
" }}}

" {{{ Global functions
" Pattern MATCHES zero-width if the preceding atom does NOT match just
" before what follows. Here it won't match '\ ' because preceding atom
" matches just before what follows.
" It's run when a file is opened
function! essentials#editor#MatchWhiteSpace()
    if s:shouldMatchWhitespace()
        exe 'match essentials_remove_whitespace_color /\\\@<!' . s:eol_whitespace_pattern . '$/'
    else
        exe 'match essentials_remove_whitespace_color /^^/'
    endif
endfunction

" Matches whitespace up to cursor position. If cursor position is
" non-whitespace '\%#'then it won't match for invalid spaces before
function! essentials#editor#MatchWhiteSpaceInsertEnter()
    if s:shouldMatchWhitespace()
        exe 'match essentials_remove_whitespace_color /\\\@<!' . s:eol_whitespace_pattern . '\%#\@<!$/'
    endif
endfunction

function! essentials#editor#RemoveWhiteSpace(line1,line2)
    let l:save_cursor = getpos(".")
    silent! execute ':' . a:line1 . ',' . a:line2 . 's/\\\@<!'. s:eol_whitespace_pattern. '$//'
    call setpos('.', l:save_cursor)
endfunction
" }}}
