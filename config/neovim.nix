{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      customRC = ''
        " settings
        set autoindent
        set autoread
        set autowrite
        set clipboard=unnamedplus
        set cursorcolumn
        set cursorline
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
        set nrformats=hex,alpha
        set nohlsearch
        set nojoinspaces
        set noshowmode
        set noruler
        set number
        set printoptions=number:y,paper:letter
        set shada='20,<500,h
        set showmatch
        set smartcase
        set smarttab
        set scrolloff=2
        set showcmd
        set undofile
        set wildmenu

        " tabbing
        set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab

        " color scheme
        colorscheme jellybeans

        " features
        filetype plugin indent on
        syntax enable

        " autocommands
        autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
        autocmd BufNewFile,BufRead *.ly let b:commentary_format = '%%s' | compiler lilypond
        autocmd BufNewFile,BufRead *.tex let b:tex_flavor = 'pdflatexmk' | compiler tex

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
        let g:vimwiki_list=[{'path': '$HOME/docs/wiki'}]

        " vim-sonic-pi
        let g:sonic_pi_run_args = ['--cue-server', 'external']

        " nvim-lspconfig
        lua << EOF
        local servers = {
          pylsp = {
            settings = {
              pylsp = {
                plugins = {
                  pycodestyle = {
                    ignore = { 'E501' }
                  }
                }
              }
            }
          },
          rust_analyzer = {},
          nil_ls = {},
          bashls = {},
        }

        local nvim_lsp = require('lspconfig')

        local on_attach = function(client, bufnr)
          local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
          local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

          buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

          local opts = { noremap = true, silent = true }

          buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          buf_set_keymap('n', '<leader>la', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
          buf_set_keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
          buf_set_keymap('n', '<leader>ll', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
          buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          buf_set_keymap('n', '<leader>R', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          buf_set_keymap('n', '<leader>C', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
          buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.hide()<cr>', opts)
          buf_set_keymap('n', '<leader>E', '<cmd>lua vim.diagnostic.show()<cr>', opts)
          buf_set_keymap('n', '<leader>F', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
          buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
          buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
          buf_set_keymap('n', '<leader>Q', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)
          buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)
        end

        for server, extra_args in pairs(servers) do
          local args = {
            on_attach = on_attach,
            flags = {
              debounce_text_changes = 150,
            }
          }

          for key, val in pairs(extra_args) do
            args[key] = val
          end

          nvim_lsp[server].setup(args)
        end
        EOF
      '';

      packages.fooster = with pkgs.vimPlugins; {
        start = [
          jellybeans-vim
          lightline-vim
          nvim-lspconfig
          rust-vim
          vim-abolish
          vim-better-whitespace
          vim-commentary
          vim-easy-align
          vim-elixir
          vim-eunuch
          vim-expand-region
          vim-fugitive
          vim-multiple-cursors
          vim-nix
          vim-peekaboo
          vim-ps1
          vim-qml
          vim-repeat
          vim-slash
          vim-sleuth
          vim-speeddating
          vim-surround
          vim-unimpaired
          vim-vinegar
          vim-visual-increment

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
          vimwiki-dev
        ];
      };
    };
  };
}
