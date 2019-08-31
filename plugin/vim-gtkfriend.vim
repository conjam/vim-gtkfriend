"
"
"
"
if exists("g:loaded_gtkfriend") || &cp || v:version < 700
  finish
endif






let g:loaded_gtkfriend = 1
let g:registered_gtkfriend = 0
let g:rpc_id = '-1'



command! -nargs=0 GtkFriendAddSignal call gtkfriend#query(expand('<cword>'))
command! -nargs=0 GtkFriendRegister call gtkfriend#register()
command! -nargs=* GtkFriendOpen call gtkfriend#opengtk()
