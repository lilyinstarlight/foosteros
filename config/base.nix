{ config, lib, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
    ../modules/nixos/boot/systemd-boot/systemd-boot.nix
    ../modules/nixos/services/misc/swaynag-battery.nix
    ../modules/nixos/programs/sway.nix
    ../modules/nixos/programs/mako.nix
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.sharedModules = [
    ../modules/home-manager/services/audio/mopidy.nix
    ../modules/home-manager/services/audio/mpdris2.nix
    {
      xdg.userDirs = {
        enable = true;
        desktop = "$HOME";
        documents = "$HOME/docs";
        download ="$HOME/tmp";
        music = "$HOME/music";
        pictures = "$HOME/pics";
        publicShare = "$HOME/public";
        templates = "$HOME/.templates";
        videos = "$HOME/vids";
      };
    }
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

  nix = {
    package = pkgs.nixUnstable;

    binaryCachePublicKeys = [ "foosteros.cachix.org-1:rrDalTfOT1YohJXiMv8upgN+mFLKZp7eWW1+OGbPRww=" ];
    binaryCaches = [ "https://foosteros.cachix.org/" ];

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = (pkgs: import ../pkgs { inherit pkgs; });
  };

  environment.variables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    "nix/nixpkgs-config.nix".text = lib.mkDefault ''
      {
        allowUnfree = true;
        packageOverrides = (pkgs: import /etc/nixos/pkgs { inherit pkgs; });
      }
    '';

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
      XDG_DESKTOP_DIR="$HOME"
      XDG_DOCUMENTS_DIR="$HOME/docs"
      XDG_DOWNLOAD_DIR="$HOME/tmp"
      XDG_MUSIC_DIR="$HOME/music"
      XDG_PICTURES_DIR="$HOME/pics"
      XDG_PUBLICSHARE_DIR="$HOME/public"
      XDG_TEMPLATES_DIR="$HOME/.templates"
      XDG_VIDEOS_DIR="$HOME/vids"
    '';

    gitconfig.text = lib.mkDefault ''
      [core]
      	pager = "${pkgs.gitAndTools.delta}/bin/delta --dark"

      [interactive]
      	diffFilter = "${pkgs.gitAndTools.delta}/bin/delta --dark --color-only"
    '';
  };

  environment.systemPackages = with pkgs; [
    bc file htop python3 tree unzip
    fishPlugins.done
    tmux tmuxPlugins.sensible tmuxPlugins.yank tmuxPlugins.logging
    cachix fpaste ftmp furi
    git gitAndTools.delta ripgrep
    shellcheck progress
  ];

  environment.shellAliases = {
    ls = "ls --color=tty -h";
    df = "df -h";
    du = "du -h";
    free = "free -h";
    bc = "bc -l";
    curl = "curl -L";
    cget = "command curl -fLJO --progress-bar --retry 10 -C -";
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting ""

      set fish_color_command magenta
      set fish_color_comment brblack
      set fish_color_cwd cyan
      set fish_color_end green
      set fish_color_error red
      set fish_color_escape brblue
      set fish_color_host blue
      set fish_color_operator brblue
      set fish_color_params blue
      set fish_color_quote yellow
      set fish_color_redirection brblue
      set fish_color_user magenta
    '';
    promptInit = ''
      any-nix-shell fish --info-right | source
    '';
  };

  programs.tmux = {
    enable = true;

    baseIndex = 1;
    clock24 = true;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    reverseSplit = true;
    shortcut = "s";
    terminal = "screen-256color";

    extraConfig = ''
      # interaction
      setw -g mouse on
      setw -g monitor-activity on

      # style
      set -g status-style fg=colour246,bg=colour236
      set -g window-status-activity-style fg=colour235,bg=colour241
      set -g window-status-current-style fg=colour236,bg=colour245

      # key bindings
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      bind-key M-j resize-pane -D
      bind-key M-k resize-pane -U
      bind-key M-h resize-pane -L
      bind-key M-l resize-pane -R

      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # plugins
      set -g @logging-path '$HOME/tmp'
      set -g @screen-capture-path '$HOME/tmp'
      set -g @save-complete-history-path '$HOME/tmp'
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
          vim-visual-increment
          vimwiki

          hexmode
          vim-fish
          vim-interestingwords
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

  sound.enable = true;

  services.openssh.enable = true;

  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";

    libinput.enable = true;
  };
}
