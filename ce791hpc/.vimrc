set nocompatible              " required
set encoding=utf-8
filetype off                  " required
filetype on

" detect changes made outside of vim
set autoread 
au CursorHold * checktime

set ruler		" show the cursor position all the time

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
"Plugin 'vim-scripts/indentpython.vim'
Plugin 'The-NERD-Commenter'
"Plugin 'scrooloose/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'jnurmine/Zenburn'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-fugitive'
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'craigemery/vim-autotag'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" this does the red highlighting of bad whitepsace and not sure what else
"let python_highlight_all=1

" bracket matching
"inoremap { {<CR><BS>}<Esc>ko
"inoremap {<CR> {<CR>}<C-o>O
" https://stackoverflow.com/questions/21316727/automatic-closing-brackets-for-vim
"inoremap " ""<left>
"inoremap ' ''<left>
"inoremap ( ()<left>
"inoremap [ []<left>
"inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" map esc to jj for fast normal mode switch
imap jj <ESC>

" map j and k to work on line wraps for long paragrpahs / report writing
map j gj
map k gk

" allow the delete key to work correctly
set backspace=indent,eol,start

" change tabstop size to 4
set tabstop=4
set shiftwidth=4

" fortran stuff
let fortran_free_source=1
let fortran_have_tabs=1
let fortran_more_precise=1
let fortran_do_enddo=1
"syn match fortranComment excludenl "^[!c*].*$" contains=@fortranCommentGroup,@spell
"syn match fortranComment excludenl "!.*$" contains=@fortranCommentGroup,@spell

syntax on

"au BufNewFile,BufRead *.py
"    \ set tabstop=4
"    \ set softtabstop=4
"    \ set shiftwidth=4
"    \ set textwidth=79
"    \ set expandtab
"    \ set autoindent
"    \ set fileformat=unix

"au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

"python with virtualenv support
"py << EOF
"import os
"import sys
"if 'VIRTUAL_ENV' in os.environ:
"  project_base_dir = os.environ['VIRTUAL_ENV']
"  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"  execfile(activate_this, dict(__file__=activate_this))
"EOF

if has('gui_running')
  set background=dark
  colorscheme matrix
else
  colorscheme matrix 
endif

"call togglebg#map("<F5>")

" yank to clipboard
if has("clipboard")
  set clipboard=unnamed " copy to the system clipboard

  if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
  endif
endif

set nu
"set clipboard+=unnamed
set splitbelow
set splitright

set undodir=~/.vim/undodir
set undofile

" copy and paste keeping original in buffer
xnoremap p pgvy

" auto save sessions
function! FindProjectName()
  let s:name = getcwd()
  if !isdirectory(".git")
    let s:name = substitute(finddir(".git", ".;"), "/.git", "", "")
  end
  if s:name != ""
    let s:name = matchstr(s:name, ".*", strridx(s:name, "/") + 1)
  end
  return s:name
endfunction

" Sessions only restored if we start Vim without args.
function! RestoreSession(name)
  if a:name != ""
    if filereadable($HOME . "/.vim/sessions/" . a:name)
      execute 'source ' . $HOME . "/.vim/sessions/" . a:name
    end
  end
endfunction

" Sessions only saved if we start Vim without args.
function! SaveSession(name)
  if a:name != ""
    execute 'mksession! ' . $HOME . '/.vim/sessions/' . a:name
  end
endfunction

" Restore and save sessions.
if argc() == 0
  autocmd VimEnter * call RestoreSession(FindProjectName())
  autocmd VimLeave * call SaveSession(FindProjectName())
end

" open pdfs
:command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> -
" :command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> - |fmt -csw78
