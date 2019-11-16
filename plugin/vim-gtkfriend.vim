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
let g:gtkfriend_zoom = 0


"command! -nargs=* GtkAddSignal call gtkfriend#query(<f-args>)
command! -nargs=0 GtkRegister call gtkfriend#register()
command! -nargs=* GtkOpen call gtkfriend#opengtk(<f-args>)
command! -nargs=0 GtkTime call gtkfriend#set_time(expand('<cword>'))
command! -nargs=1 GtkTime call gtkfriend#set_time(<q-args>)
command! -nargs=* GtkZoomIn call gtkfriend#zoom_in(<q-args>)
command! -nargs=* GtkZoomOut call gtkfriend#zoom_out(<q-args>)
