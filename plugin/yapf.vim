if exists('g:loaded_yapf')
    finish
endif

try
    call operator#user#define(
        \ 'yapf',
        \ 'operator#yapf#do',
        \ 'let g:operator#yapf#save_pos = getpos(".") \| let g:operator#yapf#save_screen_pos = line("w0")'
        \ )
catch /^Vim\%((\a\+)\)\=:E117/
    " vim-operator-user is not installed
endtry

command! -range=% -nargs=0 Yapf call yapf#replace(<line1>, <line2>)

command! -range=% -nargs=0 YapfEchoFormattedCode echo yapf#format(<line1>, <line2>)

augroup plugin-yapf-auto-format
    autocmd!
    autocmd BufWritePre *
        \ if &ft =~# '^\%(python\)$' &&
        \     g:yapf#auto_format &&
        \     !yapf#is_invalid() |
        \     call yapf#replace(1, line('$')) |
        \ endif
    autocmd FileType python
        \ if g:yapf#auto_format_on_insert_leave &&
        \     !yapf#is_invalid() |
        \     call yapf#enable_format_on_insert() |
        \ endif
    autocmd FileType python
        \ if g:yapf#auto_formatexpr &&
        \     !yapf#is_invalid() |
        \     setlocal formatexpr=yapf#replace(v:lnum,v:lnum+v:count-1) |
        \ endif
augroup END

command! YapfAutoToggle call yapf#toggle_auto_format()
command! YapfAutoEnable call yapf#enable_auto_format()
command! YapfAutoDisable call yapf#disable_auto_format()

let g:loaded_yapf = 1
