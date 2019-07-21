scriptencoding utf-8

" Initialization {{{
" if we have already loaded essentials or it's in compatibility mode, exit
if exists('g:loaded_essentials') || &cp | finish | endif
let g:loaded_essentials = 1

if v:version < 703 || (v:version == 703 && !has("patch105"))
  call essentials#utils#warn('requires Vim 7.3.105')
  finish
endif
" }}}

" Configure Remove White Space {{{
" Create highlight group so it is defined
highlight default essentials_remove_whitespace_color ctermbg=darkred guibg=darkred

" Prevent override by future color scheme command
" Matches white space characters: space, tab, CR, NL, vertical tab, form feed
" Also matches Unicode white space to the end
augroup RemoveWhiteSpace
    autocmd!
    autocmd ColorScheme * highlight default essentials_remove_whitespace_color ctermbg=darkred guibg=darkred
    autocmd BufRead,BufNew * call essentials#editor#MatchWhiteSpace()
    autocmd InsertLeave * call essentials#editor#MatchWhiteSpace()
    autocmd InsertEnter * call essentials#editor#MatchWhiteSpaceInsertEnter()
augroup END

" in range entire file, line1 for start and line2 for end, remove white spaces
command! -range=% RemoveWhiteSpace call essentials#editor#RemoveWhiteSpace(<line1>,<line2>)
" }}}
