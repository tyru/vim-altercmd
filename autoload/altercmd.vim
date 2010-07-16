" altercmd - Alter built-in Ex commands by your own ones
" Version: 0.0.0
" Copyright (C) 2009 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! altercmd#define(...)  "{{{2
  if a:0 == 1
    try
      let [options, lhs_list, alternate_name] = s:parse_args(a:1)
    catch /^parse error$/
      call s:echomsg('WarningMsg', 'invalid argument')
      return
    endtry
  elseif a:0 >= 4
    let [hoge, lhs, alternate_name, modes] = a:000
  else
    call s:echomsg('WarningMsg', 'invalid argument')
    return
  endif

  for lhs in lhs_list
    execute
    \ 'cnoreabbrev <expr>' . (get(options, 'buffer', 0) ? '<buffer>' : '')
    \ lhs
    \ '(getcmdtype() == ":" && getcmdline() ==# "' . lhs  . '")'
    \ '?' ('"' . alternate_name . '"')
    \ ':' ('"' . lhs . '"')
  endfor
endfunction




function! s:echomsg(hi, msg) "{{{2
  execute 'echohl' a:hi
  echomsg a:msg
  echohl None
endfunction

function! s:skip_white(q_args) "{{{2
    return substitute(a:q_args, '^\s*', '', '')
endfunction

function! s:parse_one_arg_from_q_args(q_args) "{{{2
    let arg = s:skip_white(a:q_args)
    let head = matchstr(arg, '^.\{-}[^\\]\ze\([ \t]\|$\)')
    let rest = strpart(arg, strlen(head))
    return [head, rest]
endfunction

function! s:parse_options(args) "{{{2
  let args = a:args
  let opt = {}

  while args != ''
    let o = matchstr(args, '^<[^<>]\{-1,}>')
    if o == ''
      break
    endif
    let args = strpart(args, strlen(o))

    if o ==? '<buffer>'
      let opt.buffer = 1
    endif
    let m = matchlist(o, '^<mode:\([^<>]\{-1,}\)>$')
    if !empty(m) && m[1] =~# '^[nvoiclxs]\+$'
      let opt.modes = m[1]
    endif
  endwhile

  return [opt, args]
endfunction

function! s:parse_args(args)  "{{{2
  let parse_error = 'parse error'
  let args = a:args

  let [options, args] = s:parse_options(args)
  let [original_name, args] = s:parse_one_arg_from_q_args(args)
  let [alternate_name, args] = s:parse_one_arg_from_q_args(args)


  if original_name =~ '\['
    let [original_name_head, original_name_tail] = split(original_name, '[')
    let original_name_tail = substitute(original_name_tail, '\]', '', '')
  else
    let original_name_head = original_name
    let original_name_tail = ''
  endif

  let lhs_list = []
  let original_name_tail = ' ' . original_name_tail
  for i in range(len(original_name_tail))
    let lhs = original_name_head . original_name_tail[1:i]
    call add(lhs_list, lhs)
  endfor

  return [options, lhs_list, alternate_name]
endfunction




function! altercmd#load()  "{{{2
  runtime! plugin/altercmd.vim
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
