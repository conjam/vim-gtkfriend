let s:rpc_regex='--rpcid\ \([0-9]*\)'
let s:grep_procs='vimgrep /rpcid/j  /tmp/uniqstr'


"let git_root_dir = systemlist('git rev-parse --show-toplevel')[0]

let s:plugin_dir_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:mapfile_path = '/var/tmp/mapfile'
function! s:gtkwave_live()
  let g:registered_gtkfriend = 0
  silent! call system('ps -ef | grep gtkwave > /tmp/uniqstr')
  silent! exec s:grep_procs
  let results = getqflist()
  for item in results
      let total_match = matchstr(item['text'], s:rpc_regex)
      let g:local_id = substitute(total_match,s:rpc_regex,'\1','')
      if (g:local_id == g:rpc_id)
        let g:registered_gtkfriend = 1
      endif
  endfor
  if (g:registered_gtkfriend == 0)
    "echo 'Old gtkwave died... finding new gtkwave to hook into'
    silent! call gtkfriend#register()
  endif 
endfunction

function! s:register_string(line)
  let total_match = matchstr(a:line, s:rpc_regex)
  let g:rpc_id = substitute(total_match,s:rpc_regex, '\1','')
  "echo 'gsettings set com.geda.gtkwave dump-signal-fac-offset '. g:rpc_id . ',' . s:mapfile_path
  silent call system('gsettings set com.geda.gtkwave dump-signal-fac-offset '. g:rpc_id . ',' . s:mapfile_path)
  silent cclose
endfunction





function! gtkfriend#opengtk(...)
  if (a:0 > 0)
    let g:rpc_id = system('echo $RANDOM') % 15000
    silent! call system("gtkwave --rpcid " . g:rpc_id . " " . a:1)
    return
  endif
  let git_root = system('git rev-parse --show-toplevel')
  "FIXME: this is.. not the best way to do this
  if "fatal:" == split(git_root)[0]
    echom "Not in git directory"
    return
  endif
  let vcdlist = split(system('find ' . git_root[:-2] . ' -name "*.vcd"'), "\n")
  if len(vcdlist) == 0
    echom "No valid vcd files in this git directory"
    return
  elseif  len(vcdlist) == 1
    let g:rpc_id = system('echo $RANDOM') % 15000
    silent! call "gtkwave --rpcid " . g:rpc_id . " " . vcdlist[0]
  else
    let g:rpc_id = system('echo $RANDOM') % 15000
    call s:hijack_copen(vcdlist, 'open')
  endif
  let g:registered_gtkfriend = 1
  return
endfunction
    



function! gtkfriend#register()
  if ("g:registered_gtkfriend" == 1)
    return 
  endif 
  "FIXME: make this actually unique?
  silent! call system('ps -ef | grep gtkwave > /tmp/uniqstr') 
  silent! exec s:grep_procs
  let results= getqflist()
  echo results
  if (len(results) == 0)
    echom "No valid gtkprocs running"
  elseif (len(results) == 1)
    call s:register_string(results[0]['text'])
  else 
    call gtkfriend#prettify_qf_layout_and_map_keys(results,'register')
  endif
  let g:registered_gtkfriend = 1
  echom g:rpc_id
  return 
endfunction


function! gtkfriend#query(...) abort
  silent! call s:gtkwave_live()
  if g:registered_gtkfriend == 0 
    echom "No valid gtkwave process currently live!"
    return
  endif
  let word = expand('<cword>')
  if a:0 > 0
    let word = a:1
  endif
  let cmd = "vimgrep /".word."/j  " . s:mapfile_path 
  silent! exec cmd
  let results=getqflist()
  if (len(results) == 0)
    echo 'No signal match'
  elseif (len(results) == 1)
    let mappings = split(results[0]['text'])
    silent call system('gsettings set com.geda.gtkwave add-signal-fac-offset ' . g:rpc_id . ',' . mappings[-1])
    echom 'Added ' . mappings[0] . ' to gtkwave!'
  else
    call gtkfriend#prettify_qf_layout_and_map_keys(results,'query')
  endif
endfunction

function! gtkfriend#query_string(line)
  let fac_num = split(a:line)[-1]
  silent call system('gsettings set com.geda.gtkwave add-signal-fac-offset ' . g:rpc_id .',' . fac_num)
  silent cclose
endfunction






function! s:hijack_copen(results, mode)
  copen
  setlocal modifiable
  setlocal nolist
  setlocal nowrap

  " delete all the text in qf
  silent %delete
  call append('0', a:results)
  global/^$/delete
  if a:mode == "open"
    nnoremap <buffer> <Enter> :call system("gtkwave --rpcid " . g:rpc_id . " " . getline('.') . " &") <CR> :cclose <CR>
  endif

  normal! gg
  " lock qf again
  setlocal nomodifiable
  setlocal nomodified

endfunction




" Ref: MarcWeber's vim-addon-qf-layout
"      Ripped from codequery-vim, thank you Joe
function! gtkfriend#prettify_qf_layout_and_map_keys(results,mapping) abort
    copen
    
    " unlock qf to make changes
    setlocal modifiable
    setlocal nolist
    setlocal nowrap

    " delete all the text in qf
    silent %delete

    " insert new text with pretty layout
    let max_fn_len = 0
    let max_lnum_len = 0
    for d in a:results
        let d['filename'] = bufname(d['bufnr'])
        let max_fn_len = max([max_fn_len, len(d['filename'])])
        let max_lnum_len = max([max_lnum_len, len(d['lnum'])])
    endfor
    let reasonable_max_len = 60
    let max_fn_len = min([max_fn_len, reasonable_max_len])
    if (a:mapping == 'register')
      let qf_format = '"%-' . max_fn_len . 'S | %' . max_lnum_len . 'S | %s"'
      let evaluating_str = 'printf(' . qf_format .
                      \ ', v:val["filename"], v:val["lnum"], v:val["text"])'
    elseif (a:mapping == 'query')
      let qf_format = '" %s"'
      let evaluating_str = 'printf(' . qf_format .
                      \ ',  v:val["text"])'
    endif 
    call append('0', map(a:results, evaluating_str))

    " delete empty line
    global/^$/delete

    " put the cursor back

    if (a:mapping == 'register')
      nnoremap <buffer> <Enter> :call gtkfriend#register_string(getline('.'))<CR>
    elseif (a:mapping == 'query')
      nnoremap <buffer> <Enter> :call gtkfriend#query_string(getline('.')) <CR> :echo ''<CR>
      
    endif
    normal! gg
    " lock qf again
    setlocal nomodifiable
    setlocal nomodified
endfunction


function! gtkfriend#dogman(word) abort
  echo a:word
  return
endfunction


function! gtkfriend#set_time(time) abort
  silent! call s:gtkwave_live()
  if g:registered_gtkfriend == 0 
    echom "No valid gtkwave process currently live!"
    return
  endif
  silent call system('gsettings set com.geda.gtkwave move-to-time ' . g:rpc_id .',' . a:time) 
endfunction

function! gtkfriend#zoom_out(...) abort
  silent! call s:gtkwave_live()
  if g:registered_gtkfriend == 0 
    echom "No valid gtkwave process currently live!"
    return
  endif
  let zoom_factor = 1
  if a:0 > 0
    let zoom_factor = a:1
  endif
  let g:gtkfriend_zoom = g:gtkfriend_zoom - zoom_factor
  silent call system('gsettings set com.geda.gtkwave zoom-size ' . g:rpc_id .',' . g:gtkfriend_zoom) 
endfunction

function! gtkfriend#zoom_in(...) abort
  silent! call s:gtkwave_live()
  if g:registered_gtkfriend == 0 
    echom "No valid gtkwave process currently live!"
    return
  endif
  let zoom_factor = 1
  if a:0 > 0
    echom a:1
    let zoom_factor = a:1
  endif
  if g:gtkfriend_zoom < 0
    let g:gtkfriend_zoom = g:gtkfriend_zoom + zoom_factor
  else
    let g:gtkfriend_zoom = 0
  endif
  if g:gtkfriend_zoom > 30
    let g:gtkfriend_zoom = 30
  endif
  silent call system('gsettings set com.geda.gtkwave zoom-size ' . g:rpc_id .',' . g:gtkfriend_zoom) 
endfunction




" Taken from codequery-vim
function! gtkfriend#is_valid_word(word) abort
    return strlen(matchstr(a:word, '\v^[a-z|A-Z|0-9|_|*|?]+$')) > 0
endfunction


function! gtkfriend#get_valid_cursor_word() abort
    return codequery#is_valid_word(expand('<cword>')) ? expand('<cword>') : ''
endfunction

