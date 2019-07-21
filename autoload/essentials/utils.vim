
function! essentials#utils#warn(message) abort
  echohl WarningMsg
  echo 'vim-essentials: ' . a:message
  echohl None
  let v:warningmsg = a:message
endfunction
