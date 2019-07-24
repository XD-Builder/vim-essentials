scriptencoding utf-8

" {{{ Initialization
" if we have already loaded essentials or it's in compatibility mode, exit
if exists('g:loaded_essentials') || &cp | finish | endif
let g:loaded_essentials = 1

if v:version < 703 || (v:version == 703 && !has("patchier"))
  call essentials#utils#warn('requires Vim 7.3.105')
  finish
endif
" }}}

" {{{ EssentialsRemoveWhiteSpace Setup
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
" }}}

" {{{ EssentialsWebGoogle Setup
" Set configurable command for calling google
if !exists("g:essentials_web_google_command")
    let g:essentials_web_google_command = "Google"
endif

if !exists("g:essentials_web_googe_with_file_type_command")
    let g:essentials_web_googe_with_file_type_command = g:essentials_web_google_command . "f"
endif

" }}}

" {{{ Commands
" In file's entire range, replace space from start of the file to the end.
command! -range=% EssentialsRemoveWhiteSpace call essentials#editor#RemoveWhiteSpace(<line1>,<line2>)
command! -nargs=* -range EssentialsStackOverflow call essentials#web#StackOverflow(<f-args>)

execute "command! -nargs=* -range ". g:essentials_web_google_command
    \ ." :call essentials#web#Google('' ,<f-args>)"
execute "command! -nargs=* -range ". g:essentials_web_googe_with_file_type_command
    \ ." :call essentials#web#Google(&ft, <f-args>)"
" }}}
