Format your Python code
=======================================

## Requirements

- `yapf` command
- [vim-operator-user](https://github.com/kana/vim-operator-user)(highly recommended)
- [vimproc.vim](https://github.com/Shougo/vimproc.vim)(recommended in Windows)

## Installation

Copy `plugin`, `doc` and `autoload` directories into your `~/.vim` or use `:packadd` in Vim8. Or please use your favorite plugin manager to install this plugin. I recommend latter.

## Usage

`:Yapf` command is available.
If you use it in normal mode, the whole code will be formatted. If you use it in visual mode, the selected code will be formatted.
It is more convenient to map `:Yapf` to your favorite key mapping in normal mode and visual mode.

If you install [vim-operator-user](https://github.com/kana/vim-operator-user) in advance, you can also map `<Plug>(operator-clang-format)` to your favorite key bind.

`:YapfAutoToggle` command toggles the auto formatting on buffer write.
`:YapfAutoEnable` command enables the auto formatting on buffer write. Useful for automatically enabling the auto format through a vimrc. `:ClangFormatAutoDisable` turns it off.

## Customization

You can customize formatting using some variables.

- `g:yapf#code_style`

`g:yapf#code_style` is a base style.
`pep8`, `google` is supported.
The default value is `pep8`.

- `g:yapf#command`

Name of `clang-format`. If the name of command is not `clang-format`
or you want to specify a command by absolute path, set this variable.
Default value is `clang-format`.

- `g:yapf#extra_args`

You can specify more extra options in `g:yapf#extra_args` as String or List of String.

> - `g:yapf#detect_style_file`

> When this variable's value is `1`, vim-clang-format automatically detects the style file like
> `.clang-format` or `_clang-format` and applies the style to formatting.

- `g:yapf#auto_format`

When the value is 1, a current buffer is automatically formatted on saving the buffer.
Formatting is executed on `BufWritePre` event.

- `g:yapf#auto_format_on_insert_leave`

When the value is 1, inserted lines are automatically formatted on leaving insert mode.
Formatting is executed on `InsertLeave` event.

- `g:yapf#auto_formatexpr`

When the value is 1, `formatexpr` option is set by vim-clang-format automatically in C, C++ and ObjC codes.
Vim's format mappings (e.g. `gq`) get to use `clang-format` to format. This
option is not comptabile with Vim's `textwidth` feature. You must set
`textwidth` to `0` when the `formatexpr` is set.

## Vimrc Example

```vim
" map to <Leader>cf in C++ code
autocmd FileType python nnoremap <buffer><Leader>cf :<C-u>Yapf<CR>
autocmd FileType python vnoremap <buffer><Leader>cf :Yapf<CR>
" if you install vim-operator-user
autocmd FileType python map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
nmap <Leader>C :YapfAutoToggle<CR>
```

### Auto-enabling auto-formatting

```vim
autocmd FileType c YapfAutoEnable
```

## For More Information

```
$ yapf --help
```

## License

    The MIT License (MIT)

    Copyright (c) 2017 Ben Yip

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
