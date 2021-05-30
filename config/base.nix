{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/nixos/boot/systemd-boot/systemd-boot.nix
    ../modules/nixos/services/misc/swaynag-battery.nix
    ../modules/nixos/programs/sway.nix
    ../modules/nixos/programs/mako.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      bootName = "FoosterOS/2 Warp";
    };
  };

  networking.useDHCP = false;
  networking.useNetworkd = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time.timeZone = "America/New_York";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (self: super: (import ../pkgs/default.nix { pkgs = super; }))
    ];
  };

  environment.variables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    issue.source = lib.mkForce (pkgs.writeText "issue" ''

      Welcome to [35;1mFoosterOS/2[0m [34;1mWarp[0m - \l

    '');

    os-release.text = lib.mkForce ''
      NAME=NixOS
      ID=nixos
      VERSION="${config.system.nixos.version} (${config.system.nixos.codeName})"
      VERSION_CODENAME=${lib.toLower config.system.nixos.codeName}
      VERSION_ID="${config.system.nixos.version}"
      PRETTY_NAME="FoosterOS/2 Warp"
      LOGO="nix-snowflake"
      HOME_URL="https://github.com/lilyinstarlight/foosteros"
      DOCUMENTATION_URL="https://nixos.org/learn.html"
      BUG_REPORT_URL="https://github.com/lilyinstarlight/foosteros/issues"
    '';

    "xdg/user-dirs.defaults".text = ''
      XDG_DESKTOP_DIR=$HOME
      XDG_DOCUMENTS_DIR=$HOME/docs
      XDG_DOWNLOAD_DIR=$HOME/tmp
      XDG_MUSIC_DIR=$HOME/music
      XDG_PICTURES_DIR=$HOME/pics
      XDG_PUBLICSHARE_DIR=$HOME/public
      XDG_TEMPLATES_DIR=$HOME/.templates
      XDG_VIDEOS_DIR=$HOME/vids
    '';

    gitconfig.text = lib.mkDefault ''
      [core]
      	pager = "${pkgs.gitAndTools.delta}/bin/delta --dark"

      [interactive]
      	diffFilter = "${pkgs.gitAndTools.delta}/bin/delta --dark --color-only"
    '';
  };

  environment.systemPackages = with pkgs; [
    bc file htop tmux python3 tree
    cachix fooster.fpaste fooster.ftmp fooster.furi
    git gitAndTools.delta ripgrep
    shellcheck progress
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "ls --color=tty -h";
      df = "df -h";
      du = "du -h";
      free = "free -h";
      bc = "bc -l";
      curl = "curl -L";
      cget = "command curl -fLJO --progress-bar --retry 10 -C -";
    };
    shellInit = ''
      set -g fish_greeting ""
    '';
    promptInit = ''
      any-nix-shell fish --info-right | source
    '';
  };

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
        autocmd BufNewFile,BufRead *.ly compiler lilypond
        autocmd BufNewFile,BufRead *.tex let b:tex_flavor = 'pdflatexmk' | compiler tex

        " vim
        nnoremap Y y$
        nmap <leader>n :ene<cr>
        nmap <leader>d :%d<cr>
        nmap <leader>l :set list!<cr>
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
        nmap <leader>q :.!bc<cr>
        vmap <leader>q :!bc<cr>
        nmap <leader><cr> :make %<cr>

        " matchit.vim
        runtime! macros/matchit.vim

        " netrw
        let g:netrw_list_hide='\(^\|\s\s\)\zs\.\S\+'
        nmap <leader>e :Explore<cr>

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
      '';

      packages.fooster = with pkgs; {
        start = [
          vimPlugins.jellybeans-vim
          vimPlugins.lightline-vim
          vimPlugins.vim-abolish
          vimPlugins.vim-better-whitespace
          vimPlugins.vim-commentary
          vimPlugins.vim-easy-align
          vimPlugins.vim-elixir
          vimPlugins.vim-eunuch
          vimPlugins.vim-expand-region
          vimPlugins.vim-fugitive
          vimPlugins.vim-multiple-cursors
          vimPlugins.vim-nix
          vimPlugins.vim-peekaboo
          vimPlugins.vim-ps1
          vimPlugins.vim-qml
          vimPlugins.vim-repeat
          vimPlugins.vim-slash
          vimPlugins.vim-sleuth
          vimPlugins.vim-speeddating
          vimPlugins.vim-surround
          vimPlugins.vim-visual-increment
          vimPlugins.vimwiki

          fooster.vimPlugins.hexmode
          fooster.vimPlugins.vim-fish
          fooster.vimPlugins.vim-interestingwords
          fooster.vimPlugins.vim-lilypond-integrator
          fooster.vimPlugins.vim-radical
          fooster.vimPlugins.vim-resolve
          fooster.vimPlugins.vim-sonic-pi
          fooster.vimPlugins.vim-spl
          fooster.vimPlugins.vim-zeek
        ];
      };
    };
  };

  sound.enable = true;

  services.openssh.enable = true;

  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";

    libinput.enable = true;
  };
}
