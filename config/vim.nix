{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.vim {
  programs.vim = {
    enable = true;
    defaultEditor = true;

    package = (pkgs.vimUtils.makeCustomizable (pkgs.vim-classic.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++
      # unfortunately cannot cross-compile with python3 or ruby since it gets paths from executables
      (lib.optionals (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) [
        pkgs.python3
        pkgs.ruby
      ]);

      buildInputs = (old.buildInputs or []) ++ [
        # clipboard support
        pkgs.libx11
        pkgs.libxt
        # lua support
        pkgs.lua
      ];

      configureFlags = (old.configureFlags or []) ++ [
        # lua support
        "--with-lua-prefix=${pkgs.lua}"
        "--enable-luainterp"
        # python3 support
        "--enable-python3interp=yes"
        "--with-python3-config-dir=${pkgs.python3}/lib"
        "--disable-pythoninterp"
        # ruby support
        "--enable-rubyinterp"
      ];

      # vi symlink
      postInstall = (old.postInstall or "") + ''
        ln -s $out/bin/vim $out/bin/vi
      '';
    }))).customize {
      vimrcConfig = {
        customRC = ''
          " settings
          set autochdir
          set autoindent
          set autoread
          set autowrite
          set backspace=indent,eol,start
          set backupdir=$HOME/.local/share/vim/backup//
          set clipboard=unnamedplus
          set cursorcolumn
          set cursorline
          set directory=$HOME/.local/share/vim/swap//
          set display=lastline
          set encoding=utf-8
          set formatoptions+=n,j
          set hidden
          set history=50
          set ignorecase
          set incsearch
          set laststatus=2
          set listchars=eol:$,tab:>-,space:.,trail:#,extends:>,precedes:<,conceal:*,nbsp:+
          set mouse=a
          set nocompatible
          set nohlsearch
          set nojoinspaces
          set noruler
          set noshowmode
          set nrformats=hex,alpha
          set number
          set printoptions=number:y,paper:letter
          set scrolloff=2
          set showcmd
          set showmatch
          set smartcase
          set smarttab
          set undodir=$HOME/.local/share/vim/undo/
          set undofile
          set viminfo='20,<500,h
          set wildmenu

          " tabbing
          set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab

          " color scheme
          colorscheme jellybeans

          " features
          filetype plugin indent on
          syntax enable

          " autocommands
          augroup vimrc
            autocmd!
            autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
            autocmd BufNewFile,BufRead *.ly let b:commentary_format = '%%s' | compiler lilypond
            autocmd BufNewFile,BufRead *.tex let b:tex_flavor = 'pdflatexmk' | compiler tex
          augroup END

          " vim
          nnoremap Y y$
          nmap <leader>n :ene<cr>
          nmap <leader>d :%d<cr>
          nmap <leader><tab> :set list!<cr>
          nmap <leader>s :w<cr>
          nmap <leader>t :tabe<cr>
          nmap <leader>c :clo<cr>
          nmap <leader>u :bd!<cr>
          nmap <leader>a :bel new<cr>:te<cr>
          nmap <leader>v :set virtualedit=all<cr>
          nmap <leader>g :set virtualedit=<cr>
          nmap <leader>b :Hexmode<cr>
          nmap <leader>p :.!xargs 
          vmap <leader>p :!xargs 
          nmap <leader>q :.!qalc<cr>
          vmap <leader>q :!qalc<cr>
          nmap <leader><cr> :make %<cr>

          " matchit.vim
          runtime! macros/matchit.vim

          " netrw
          let g:netrw_list_hide='\(^\|\s\s\)\zs\.\S\+'

          " lightline.vim
          let g:lightline={'colorscheme': 'jellybeans'}

          " vim-easy-align
          nmap ga <Plug>(EasyAlign)
          xmap ga <Plug>(EasyAlign)

          " vim-better-whitespace
          nmap <leader><space> :StripWhitespace<cr>

          " vimwiki
          let g:vimwiki_global_ext=0
          let g:vimwiki_dir_link='index'
          let g:vimwiki_listsyms=' .-ox'
          let g:vimwiki_listsym_rejected='!'
          let g:vimwiki_list=[{'path': '$HOME/docs/wiki'}]

          " vim-sonic-pi
          let g:sonic_pi_run_args=['--cue-server', 'external']

          " vim-lsp
          let g:lsp_diagnostics_echo_cursor = 1
          let g:lsp_diagnostics_float_cursor = 1
          let g:lsp_diagnostics_virtual_text_enabled = 0
          let g:lsp_document_code_action_signs_enabled = 0

          if executable('bash-language-server')
            autocmd User lsp_setup call lsp#register_server({
            \   'name': 'bash-language-server',
            \   'cmd': {server_info->['bash-language-server']},
            \   'allowlist': ['sh'],
            \ })
          endif
          if executable('nil')
            autocmd User lsp_setup call lsp#register_server({
            \   'name': 'nil',
            \   'cmd': {server_info->['nil']},
            \   'allowlist': ['nix'],
            \ })
          endif
          if executable('pylsp')
            autocmd User lsp_setup call lsp#register_server({
            \   'name': 'pylsp',
            \   'cmd': {server_info->['pylsp']},
            \   'allowlist': ['python'],
            \   'config': {
            \     'plugins': {
            \       'pycodestyle': {
            \         'ignore': ['E501'],
            \       },
            \     },
            \   },
            \ })
          endif
          if executable('rust-analyzer')
            autocmd User lsp_setup call lsp#register_server({
            \   'name': 'rust-analyzer',
            \   'cmd': {server_info->['rust-analyzer']},
            \   'allowlist': ['rust'],
            \   'initialization_options': {
            \     'completion': {
            \       'autoimport': { 'enable': v:true },
            \     },
            \   },
            \ })
          endif

          function! s:on_lsp_buffer_enabled() abort
              setlocal omnifunc=lsp#complete
              if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
              nnoremap <buffer> gD <plug>(lsp-declaration)
              nnoremap <buffer> gd <plug>(lsp-definition)
              nnoremap <buffer> K <plug>(lsp-hover)
              nnoremap <buffer> gi <plug>(lsp-implementation)
              nnoremap <buffer> <c-k> <plug>(lsp-signature-help)
              nnoremap <buffer> <leader>D <plug>(lsp-type-definition)
              nnoremap <buffer> <leader>R <plug>(lsp-rename)
              nnoremap <buffer> <leader>C <plug>(lsp-code-action)
              vnoremap <buffer> <leader>C <plug>(lsp-code-action)
              nnoremap <buffer> gr <plug>(lsp-references)
              nnoremap <buffer> [d <plug>(lsp-previous-diagnostic)
              nnoremap <buffer> ]d <plug>(lsp-next-diagnostic)
              nnoremap <buffer> <leader>Q <plug>(lsp-document-diagnostics)
              nnoremap <buffer> <leader>S <plug>(lsp-document-symbol)
              nnoremap <buffer> <leader>X <plug>(lsp-code-lens)
              nnoremap <buffer> gx <plug>(lsp-document-link-open)
              nnoremap <buffer> <leader>f <plug>(lsp-document-format)
              xnoremap <buffer> <leader>f <plug>(lsp-document-range-format)
              nnoremap <buffer> <expr> <c-f> lsp#scroll(+4)
              nnoremap <buffer> <expr> <c-d> lsp#scroll(-4)
          endfunction
          augroup lsp_install
            autocmd!
            autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
          augroup END
        '';

        packages.fooster = with pkgs.vimPlugins; {
          start = [
            jellybeans-vim
            lightline-vim
            rust-vim
            vim-abolish
            vim-better-whitespace
            vim-commentary
            vim-easy-align
            vim-elixir
            vim-eunuch
            vim-expand-region
            vim-fugitive
            vim-ledger
            vim-lsp
            vim-multiple-cursors
            vim-nix
            vim-peekaboo
            vim-ps1
            vim-repeat
            vim-slash
            vim-sleuth
            vim-speeddating
            vim-surround
            vim-unimpaired
            vim-vinegar
            vim-visual-increment
            vim-wayland-clipboard
            vimwiki

            hexmode
            vim-fish
            vim-interestingwords
            vim-jdaddy
            vim-lilypond-integrator
            vim-radical
            vim-resolve
            vim-sonic-pi
            vim-spl
            vim-zeek
          ];
        };
      };
    };
  };

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".local/share/vim"
        ];
      };
    };
  };
}
