let s:save_cpo = &cpo
set cpo&vim

let s:on_windows = has('win32') || has('win64')

" helper functions {{{
function! s:has_vimproc()
  if !exists('s:exists_vimproc')
    try
      silent call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif
  return s:exists_vimproc
endfunction

function! s:system(str, ...)
  let command = a:str
  let input = a:0 >= 1 ? a:1 : ''

  if a:0 == 0
    let output = s:has_vimproc() ?
          \ vimproc#system(command) : system(command)
  elseif a:0 == 1
    let output = s:has_vimproc() ?
          \ vimproc#system(command, input) : system(command, input)
  else
    " ignores 3rd argument unless you have vimproc.
    let output = s:has_vimproc() ?
          \ vimproc#system(command, input, a:2) : system(command, input)
  endif

  return output
endfunction

function! s:create_keyvals(key, val) abort
  if type(a:val) == type({})
    return a:key . ': {' . s:stringize_options(a:val) . '}'
  else
    return a:key . ': ' . a:val
  endif
endfunction

function! s:stringize_options(opts) abort
  let dict_type = type({})
  let keyvals = map(items(a:opts), 's:create_keyvals(v:val[0], v:val[1])')
  return join(keyvals, ',')
endfunction

function! s:build_extra_options()
  let extra_options = ''

  let opts = copy(g:yapf#style_options)
  if has_key(g:yapf#filetype_style_options, &ft)
    call extend(opts, g:yapf#filetype_style_options[&ft])
  endif

  let extra_options .= ', ' . s:stringize_options(opts)

  return extra_options
endfunction

function! s:success(result)
  return (s:has_vimproc() ? vimproc#get_last_status() : v:shell_error) == 0
        \ && a:result !~# '^YAML:\d\+:\d\+: error: unknown key '
endfunction

function! s:error_message(result)
  echoerr 'yapf has failed to format.'
  if a:result =~# '^YAML:\d\+:\d\+: error: unknown key '
    echohl ErrorMsg
    for l in split(a:result, "\n")[0:1]
      echomsg l
    endfor
    echohl None
  endif
endfunction

function! yapf#is_invalid()
  if !exists('s:command_available')
    if !executable(g:yapf#command)
      return 1
    endif
    let s:command_available = 1
  endif

  return 0
endfunction

function! s:verify_command()
  let invalidity = yapf#is_invalid()
  if invalidity == 1
    echoerr "yapf is not found. check g:yapf#command."
  endif
endfunction

function! s:shellescape(str) abort
  if s:on_windows && (&shell =~? 'cmd\.exe')
    return '^"' . substitute(substitute(substitute(a:str,
          \ '[&|<>()^"%]', '^\0', 'g'),
          \ '\\\+\ze"', '\=repeat(submatch(0), 2)', 'g'),
          \ '\^"', '\\\0', 'g') . '^"'
  endif
  return shellescape(a:str)
endfunction

" }}}

" variable definitions {{{
function! s:getg(name, default)
  " backward compatibility
  if exists('g:operator_'.substitute(a:name, '#', '_', ''))
    echoerr 'g:operator_'.substitute(a:name, '#', '_', '').' is deprecated. Please use g:'.a:name
    return g:operator_{substitute(a:name, '#', '_', '')}
  else
    return get(g:, a:name, a:default)
  endif
endfunction

let g:yapf#command = s:getg('yapf#command', 'yapf')
let g:yapf#extra_args = s:getg('yapf#extra_args', "")
if type(g:yapf#extra_args) == type([])
  let g:yapf#extra_args = join(g:yapf#extra_args, " ")
endif

let g:yapf#code_style = s:getg('yapf#code_style', 'pep8')
let g:yapf#style_options = s:getg('yapf#style_options', {})
let g:yapf#filetype_style_options = s:getg('yapf#filetype_style_options', {})

" let g:yapf#detect_style_file = s:getg('yapf#detect_style_file', 1)
let g:yapf#auto_format = s:getg('yapf#auto_format', 0)
let g:yapf#auto_format_on_insert_leave = s:getg('yapf#auto_format_on_insert_leave', 0)
let g:yapf#auto_formatexpr = s:getg('yapf#auto_formatexpr', 0)
" }}}

" format codes {{{
" function! s:detect_style_file()
"   let dirname = fnameescape(expand('%:p:h'))
"   return findfile('.yapf', dirname.';') != '' || findfile('_yapf', dirname.';') != ''
" endfunction

function! yapf#format(line1, line2)
  let args = printf(' --lines %d-%d', a:line1, a:line2)
  let args .= printf(' --style %s ', g:yapf#code_style)
  " if ! (g:yapf#detect_style_file && s:detect_style_file())
  "   let args .= printf(' -style=%s ', s:make_style_options())
  " else
  "   let args .= ' -style=file '
  " endif
  " let filename = expand('%')
  " if filename !=# ''
  "   let args .= printf('-assume-filename=%s ', s:shellescape(escape(filename, " \t")))
  " endif
  let args .= g:yapf#extra_args
  let yapf = printf('%s %s --', s:shellescape(g:yapf#command), args)
  return s:system(yapf, join(getline(1, '$'), "\n"))
endfunction
" }}}

" replace buffer {{{
function! yapf#replace(line1, line2)

  call s:verify_command()

  let pos_save = getpos('.')
  let sel_save = &l:selection
  let &l:selection = 'inclusive'
  let [save_g_reg, save_g_regtype] = [getreg('g'), getregtype('g')]
  let [save_unnamed_reg, save_unnamed_regtype] = [getreg(v:register), getregtype(v:register)]

  try
    let formatted = yapf#format(a:line1, a:line2)
    if s:success(formatted)
      call setreg('g', formatted, 'V')
      silent keepjumps normal! ggVG"gp
    else
      call s:error_message(formatted)
    endif
  finally
    call setreg(v:register, save_unnamed_reg, save_unnamed_regtype)
    call setreg('g', save_g_reg, save_g_regtype)
    let &l:selection = sel_save
    call setpos('.', pos_save)
  endtry
endfunction
" }}}

" auto formatting on insert leave {{{
let s:pos_on_insertenter = []

function! s:format_inserted_area()
  let pos = getpos('.')
  " When in the same buffer
  if &modified && ! empty(s:pos_on_insertenter) && s:pos_on_insertenter[0] == pos[0]
    call yapf#replace(s:pos_on_insertenter[1], line('.'))
    let s:pos_on_insertenter = []
  endif
endfunction

function! yapf#enable_format_on_insert()
  augroup plugin-yapf-auto-format-insert
    autocmd!
    autocmd InsertEnter <buffer> let s:pos_on_insertenter = getpos('.')
    autocmd InsertLeave <buffer> call s:format_inserted_area()
  augroup END
endfunction
" }}}

" toggle auto formatting {{{
function! yapf#toggle_auto_format()
  let g:yapf#auto_format = !g:yapf#auto_format
  if g:yapf#auto_format
    echo 'Auto yapf: enabled'
  else
    echo 'Auto yapf: disabled'
  endif
endfunction
" }}}

" enable auto formatting {{{
function! yapf#enable_auto_format()
  let g:yapf#auto_format = 1
endfunction
" }}}

" disable auto formatting {{{
function! yapf#disable_auto_format()
  let g:yapf#auto_format = 0
endfunction
" }}}
let &cpo = s:save_cpo
unlet s:save_cpo
