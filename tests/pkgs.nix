{ pkgs, ... }:

with pkgs;

let
  platformCond = platforms: deriv:
    if lib.any (p: p == stdenv.hostPlatform.system) platforms then deriv else "skip";
in

lib.filterAttrs (name: value: value != "skip") {
  crossguid-lib = platformCond (lib.platforms.linux ++ lib.platforms.darwin) (runCommandNoCC "test-crossguid-lib" {
    buildInputs = [ crossguid ];
  } ''
    test -f ${crossguid}/lib/libcrossguid.a

    touch $out
  '');

  fooster-backgrounds-bin = platformCond lib.platforms.linux (runCommandNoCC "test-fooster-backgrounds-bin" {
    buildInputs = [ fooster-backgrounds which ];
  } ''
    which setbg

    touch $out
  '');

  fooster-materia-theme-index = platformCond lib.platforms.linux (runCommandNoCC "test-fooster-materia-theme-index" {
    buildInputs = [ fooster-materia-theme ];
  } ''
    test -f ${fooster-materia-theme}/share/themes/Materia-Fooster/index.theme

    touch $out
  '');

  fpaste-bin = runCommandNoCC "test-fpaste-bin" {
    buildInputs = [ fpaste ];
  } ''
    fpaste --help

    touch $out
  '';

  ftmp-bin = runCommandNoCC "test-ftmp-bin" {
    buildInputs = [ ftmp ];
  } ''
    ftmp --help

    touch $out
  '';

  furi-bin = runCommandNoCC "test-furi-bin" {
    buildInputs = [ furi ];
  } ''
    furi --help

    touch $out
  '';

  gl3w-src = platformCond (lib.platforms.linux ++ lib.platforms.darwin) (runCommandNoCC "test-gl3w-src" {
    buildInputs = [ gl3w ];
  } ''
    test -f ${gl3w}/share/gl3w/gl3w.c

    touch $out
  '');

  google-10000-english-dict = runCommandNoCC "test-google-10000-english-dict" {
    buildInputs = [ google-10000-english ];
  } ''
    test -f ${google-10000-english}/share/dict/google-10000-english.txt

    touch $out
  '';

  mkusb-bin = platformCond [ "x86_64-linux" ] (runCommandNoCC "test-mkusb-bin" {
    buildInputs = [ mkusb which ];
  } ''
    which mkusb

    touch $out
  '');

  mkwin-bin = platformCond [ "x86_64-linux" ] (runCommandNoCC "test-mkwin-bin" {
    buildInputs = [ mkwin which ];
  } ''
    which mkwin

    touch $out
  '');

  open-stage-control-bin = platformCond [ "x86_64-linux" "aarch64-linux" "i686-linux" "armv7l-linux" ] (runCommandNoCC "test-open-stage-control-bin" {
    buildInputs = [ open-stage-control ];
  } ''
    env XDG_CONFIG_HOME="$(mktemp -d)" open-stage-control --help

    touch $out
  '');

  petty-bin = runCommandNoCC "test-petty-bin" {
    buildInputs = [ petty which ];
  } ''
    which petty

    touch $out
  '';

  platform-folders-lib = runCommandNoCC "test-platform-folders-lib" {
    buildInputs = [ platform-folders ];
  } ''
    test -f ${platform-folders}/lib/libplatform_folders.so

    touch $out
  '';

  pridecat-bin = runCommandNoCC "test-pridecat-bin" {
    buildInputs = [ pridecat ];
  } ''
    pridecat --help

    touch $out
  '';

  rofi-pass-wayland-bin = platformCond lib.platforms.linux (runCommandNoCC "test-rofi-pass-wayland-bin" {
    buildInputs = [ rofi-pass-wayland ];
  } ''
    rofi-pass --help

    touch $out
  '');

  rofi-wayland-bin = platformCond lib.platforms.linux (runCommandNoCC "test-rofi-wayland-bin" {
    buildInputs = [ rofi-wayland ];
  } ''
    rofi -version

    touch $out
  '');

  sonic-pi-bin = platformCond [ "x86_64-linux" ] (runCommandNoCC "test-sonic-pi-bin" {
    buildInputs = [ sonic-pi which ];
  } ''
    which sonic-pi
    test -x ${sonic-pi}/app/server/native/aubio_onset

    touch $out
  '');

  sonic-pi-beta-bin = platformCond [ "x86_64-linux" ] (runCommandNoCC "test-sonic-pi-beta-bin" {
    buildInputs = [ sonic-pi-beta which ];
  } ''
    which sonic-pi
    test -x ${sonic-pi}/app/server/native/aubio_onset

    touch $out
  '');

  sonic-pi-tool-bin = platformCond [ "x86_64-linux" ] (runCommandNoCC "test-sonic-pi-tool-bin" {
    buildInputs = [ sonic-pi-tool ];
  } ''
    sonic-pi-tool --help

    touch $out
  '');

  swaynag-battery-bin = platformCond lib.platforms.linux (runCommandNoCC "test-swaynag-battery-bin" {
    buildInputs = [ swaynag-battery ];
  } ''
    swaynag-battery --help

    touch $out
  '');

  wtype-bin = platformCond lib.platforms.linux (runCommandNoCC "test-wtype-bin" {
    buildInputs = [ wtype ];
  } ''
    wtype || [ $? -eq 1 ]

    touch $out
  '');

  monofur-nerdfont-font = runCommandNoCC "test-monofur-nerdfont-font" {
    buildInputs = [ monofur-nerdfont ];
  } ''
    test -f ${monofur-nerdfont}/share/fonts/truetype/NerdFonts/"monofur Nerd Font Complete.ttf"

    touch $out
  '';

  pass-wayland-otp-bin = platformCond lib.platforms.linux (runCommandNoCC "test-pass-wayland-otp-bin" {
    buildInputs = [ pass-wayland-otp ];
  } ''
    pass --help
    pass otp --help

    touch $out
  '');

  hexmode-plugin = runCommandNoCC "test-hexmode-plugin" {
    buildInputs = [ vimPlugins.hexmode ];
  } ''
    test -f ${vimPlugins.hexmode}/share/vim-plugins/hexmode/plugin/hexmode.vim

    touch $out
  '';

  vim-lilypond-integrator-plugin = runCommandNoCC "test-vim-lilypond-integrator-plugin" {
    buildInputs = [ vimPlugins.vim-lilypond-integrator ];
  } ''
    test -f ${vimPlugins.vim-lilypond-integrator}/share/vim-plugins/vim-lilypond-integrator/ftplugin/lilypond.vim

    touch $out
  '';

  vim-magnum-plugin = runCommandNoCC "test-vim-magnum-plugin" {
    buildInputs = [ vimPlugins.vim-magnum ];
  } ''
    test -f ${vimPlugins.vim-magnum}/share/vim-plugins/vim-magnum/autoload/magnum.vim

    touch $out
  '';

  vim-radical-plugin = runCommandNoCC "test-vim-radical-plugin" {
    buildInputs = [ vimPlugins.vim-radical ];
  } ''
    test -f ${vimPlugins.vim-radical}/share/vim-plugins/vim-radical/plugin/radical.vim

    touch $out
  '';

  vim-fish-plugin = runCommandNoCC "test-vim-fish-plugin" {
    buildInputs = [ vimPlugins.vim-fish ];
  } ''
    test -f ${vimPlugins.vim-fish}/share/vim-plugins/vim-fish/ftplugin/fish.vim

    touch $out
  '';

  vim-interestingwords-plugin = runCommandNoCC "test-interestingwords-plugin" {
    buildInputs = [ vimPlugins.vim-interestingwords ];
  } ''
    test -f ${vimPlugins.vim-interestingwords}/share/vim-plugins/vim-interestingwords/plugin/interestingwords.vim

    touch $out
  '';

  vim-resolve-plugin = runCommandNoCC "test-vim-resolve-plugin" {
    buildInputs = [ vimPlugins.vim-resolve ];
  } ''
    test -f ${vimPlugins.vim-resolve}/share/vim-plugins/vim-resolve/ftplugin/resolve.vim

    touch $out
  '';

  vim-sonic-pi-plugin = runCommandNoCC "test-vim-sonic-pi-plugin" {
    buildInputs = [ vimPlugins.vim-sonic-pi ];
  } ''
    test -f ${vimPlugins.vim-sonic-pi}/share/vim-plugins/vim-sonic-pi/plugin/sonicpi.vim

    touch $out
  '';

  vim-spl-plugin = runCommandNoCC "test-vim-spl-plugin" {
    buildInputs = [ vimPlugins.vim-spl ];
  } ''
    test -f ${vimPlugins.vim-spl}/share/vim-plugins/vim-spl/ftplugin/spl.vim

    touch $out
  '';

  vimwiki-dev-plugin = runCommandNoCC "test-vimwiki-dev-plugin" {
    buildInputs = [ vimPlugins.vimwiki-dev ];
  } ''
    test -f ${vimPlugins.vimwiki-dev}/share/vim-plugins/vimwiki-dev/plugin/vimwiki.vim

    touch $out
  '';

  vim-zeek-plugin = runCommandNoCC "test-vim-zeek-plugin" {
    buildInputs = [ vimPlugins.vim-zeek ];
  } ''
    test -f ${vimPlugins.vim-zeek}/share/vim-plugins/vim-zeek/ftplugin/zeek.vim

    touch $out
  '';

  oscpy-import = runCommandNoCC "test-oscpy-import" {
    buildInputs = [ python3 python3Packages.oscpy ];
  } ''
    python3 -c 'import oscpy'

    touch $out
  '';
}
