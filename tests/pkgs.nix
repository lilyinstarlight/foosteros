{ pkgs, ... }:

with pkgs;

let
  ifSupported = drv: test: if drv.meta.unsupported then "skip" else test;
in

lib.filterAttrs (name: value: value != "skip") {
  crossguid-lib = ifSupported crossguid (runCommandNoCC "test-crossguid-lib" {
    buildInputs = [ crossguid ];
  } ''
    test -f ${crossguid}/lib/libcrossguid.a

    touch $out
  '');

  dnsimple-ddns-bin = ifSupported dnsimple-ddns (runCommandNoCC "test-dnsimple-ddns-bin" {
    buildInputs = [ dnsimple-ddns which ];
  } ''
    which ddns

    touch $out
  '');

  fooster-backgrounds-bin = ifSupported fooster-backgrounds (runCommandNoCC "test-fooster-backgrounds-bin" {
    buildInputs = [ fooster-backgrounds which ];
  } ''
    which setbg

    touch $out
  '');

  fooster-materia-theme-index = ifSupported fooster-materia-theme (runCommandNoCC "test-fooster-materia-theme-index" {
    buildInputs = [ fooster-materia-theme ];
  } ''
    test -f ${fooster-materia-theme}/share/themes/Materia-Fooster/index.theme

    touch $out
  '');

  fpaste-bin = ifSupported fpaste (runCommandNoCC "test-fpaste-bin" {
    buildInputs = [ fpaste ];
  } ''
    fpaste --help

    touch $out
  '');

  ftmp-bin = ifSupported ftmp (runCommandNoCC "test-ftmp-bin" {
    buildInputs = [ ftmp ];
  } ''
    ftmp --help

    touch $out
  '');

  furi-bin = ifSupported furi (runCommandNoCC "test-furi-bin" {
    buildInputs = [ furi ];
  } ''
    furi --help

    touch $out
  '');

  gl3w-src = ifSupported gl3w (runCommandNoCC "test-gl3w-src" {
    buildInputs = [ gl3w ];
  } ''
    test -f ${gl3w}/share/gl3w/gl3w.c

    touch $out
  '');

  google-10000-english-dict = ifSupported google-10000-english (runCommandNoCC "test-google-10000-english-dict" {
    buildInputs = [ google-10000-english ];
  } ''
    test -f ${google-10000-english}/share/dict/google-10000-english.txt

    touch $out
  '');

  logmail-bin = ifSupported logmail (runCommandNoCC "test-logmail-bin" {
    buildInputs = [ logmail which ];
  } ''
    which logmail

    touch $out
  '');

  mkusb-bin = ifSupported mkusb (runCommandNoCC "test-mkusb-bin" {
    buildInputs = [ mkusb which ];
  } ''
    which mkusb

    touch $out
  '');

  mkwin-bin = ifSupported mkwin (runCommandNoCC "test-mkwin-bin" {
    buildInputs = [ mkwin which ];
  } ''
    which mkwin

    touch $out
  '');

  open-stage-control-bin = ifSupported open-stage-control (runCommandNoCC "test-open-stage-control-bin" {
    buildInputs = [ open-stage-control ];
  } ''
    env XDG_CONFIG_HOME="$(mktemp -d)" open-stage-control --help

    touch $out
  '');

  petty-bin = ifSupported petty (runCommandNoCC "test-petty-bin" {
    buildInputs = [ petty which ];
  } ''
    which petty

    touch $out
  '');

  platform-folders-lib = ifSupported platform-folders (runCommandNoCC "test-platform-folders-lib" {
    buildInputs = [ platform-folders ];
  } ''
    test -f ${platform-folders}/lib/libplatform_folders.so

    touch $out
  '');

  pridecat-bin = ifSupported pridecat (runCommandNoCC "test-pridecat-bin" {
    buildInputs = [ pridecat ];
  } ''
    pridecat --help

    touch $out
  '');

  rofi-pass-wayland-bin = ifSupported rofi-pass-wayland (runCommandNoCC "test-rofi-pass-wayland-bin" {
    buildInputs = [ rofi-pass-wayland ];
  } ''
    rofi-pass --help

    touch $out
  '');

  rofi-wayland-bin = ifSupported rofi-wayland (runCommandNoCC "test-rofi-wayland-bin" {
    buildInputs = [ rofi-wayland ];
  } ''
    rofi -version

    touch $out
  '');

  sonic-pi-bin = ifSupported sonic-pi (runCommandNoCC "test-sonic-pi-bin" {
    buildInputs = [ sonic-pi which ];
  } ''
    which sonic-pi
    test -x ${sonic-pi}/app/server/native/aubio_onset

    touch $out
  '');

  sonic-pi-beta-bin = ifSupported sonic-pi-beta (runCommandNoCC "test-sonic-pi-beta-bin" {
    buildInputs = [ sonic-pi-beta which ];
  } ''
    which sonic-pi

    touch $out
  '');

  sonic-pi-tool-bin = ifSupported sonic-pi-tool (runCommandNoCC "test-sonic-pi-tool-bin" {
    buildInputs = [ sonic-pi-tool ];
  } ''
    sonic-pi-tool --help

    touch $out
  '');

  supercollider-bin = ifSupported supercollider (runCommandNoCC "test-supercollider-bin" {
    buildInputs = [ supercollider ];
  } ''
    scsynth -v

    touch $out
  '');

  supercollider-with-sc3-plugins-bin = ifSupported supercollider-with-sc3-plugins (runCommandNoCC "test-supercollider-with-sc3-plugins-bin" {
    buildInputs = [ supercollider-with-sc3-plugins ];
  } ''
    scsynth -v

    cat <<EOF >test.sc
    var err = 0;

    try {
      MdaPiano.name.postln;
    } {
      err = 1;
    };

    err.exit;
    EOF
    timeout 10s env XDG_CONFIG_HOME="$(mktemp -d)" QT_QPA_PLATFORM=minimal sclang test.sc

    touch $out
  '');

  swaynag-battery-bin = ifSupported swaynag-battery (runCommandNoCC "test-swaynag-battery-bin" {
    buildInputs = [ swaynag-battery ];
  } ''
    swaynag-battery --help

    touch $out
  '');

  wtype-bin = ifSupported wtype (runCommandNoCC "test-wtype-bin" {
    buildInputs = [ wtype ];
  } ''
    wtype || [ $? -eq 1 ]

    touch $out
  '');

  monofur-nerdfont-font = ifSupported monofur-nerdfont (runCommandNoCC "test-monofur-nerdfont-font" {
    buildInputs = [ monofur-nerdfont ];
  } ''
    test -f ${monofur-nerdfont}/share/fonts/truetype/NerdFonts/"monofur Nerd Font Complete.ttf"

    touch $out
  '');

  pass-wayland-otp-bin = ifSupported pass-wayland-otp (runCommandNoCC "test-pass-wayland-otp-bin" {
    buildInputs = [ pass-wayland-otp ];
  } ''
    pass --help
    pass otp --help

    touch $out
  '');

  hexmode-plugin = ifSupported vimPlugins.hexmode (runCommandNoCC "test-hexmode-plugin" {
    buildInputs = [ vimPlugins.hexmode ];
  } ''
    test -f ${vimPlugins.hexmode}/plugin/hexmode.vim

    touch $out
  '');

  vim-lilypond-integrator-plugin = ifSupported vimPlugins.vim-lilypond-integrator (runCommandNoCC "test-vim-lilypond-integrator-plugin" {
    buildInputs = [ vimPlugins.vim-lilypond-integrator ];
  } ''
    test -f ${vimPlugins.vim-lilypond-integrator}/ftplugin/lilypond.vim

    touch $out
  '');

  vim-magnum-plugin = ifSupported vimPlugins.vim-magnum (runCommandNoCC "test-vim-magnum-plugin" {
    buildInputs = [ vimPlugins.vim-magnum ];
  } ''
    test -f ${vimPlugins.vim-magnum}/autoload/magnum.vim

    touch $out
  '');

  vim-radical-plugin = ifSupported vimPlugins.vim-radical (runCommandNoCC "test-vim-radical-plugin" {
    buildInputs = [ vimPlugins.vim-radical ];
  } ''
    test -f ${vimPlugins.vim-radical}/plugin/radical.vim

    touch $out
  '');

  vim-fish-plugin = ifSupported vimPlugins.vim-fish (runCommandNoCC "test-vim-fish-plugin" {
    buildInputs = [ vimPlugins.vim-fish ];
  } ''
    test -f ${vimPlugins.vim-fish}/ftplugin/fish.vim

    touch $out
  '');

  vim-interestingwords-plugin = ifSupported vimPlugins.vim-interestingwords (runCommandNoCC "test-interestingwords-plugin" {
    buildInputs = [ vimPlugins.vim-interestingwords ];
  } ''
    test -f ${vimPlugins.vim-interestingwords}/plugin/interestingwords.vim

    touch $out
  '');

  vim-resolve-plugin = ifSupported vimPlugins.vim-resolve (runCommandNoCC "test-vim-resolve-plugin" {
    buildInputs = [ vimPlugins.vim-resolve ];
  } ''
    test -f ${vimPlugins.vim-resolve}/ftplugin/resolve.vim

    touch $out
  '');

  vim-sonic-pi-plugin = ifSupported vimPlugins.vim-sonic-pi (runCommandNoCC "test-vim-sonic-pi-plugin" {
    buildInputs = [ vimPlugins.vim-sonic-pi ];
  } ''
    test -f ${vimPlugins.vim-sonic-pi}/plugin/sonicpi.vim

    touch $out
  '');

  vim-spl-plugin = ifSupported vimPlugins.vim-spl (runCommandNoCC "test-vim-spl-plugin" {
    buildInputs = [ vimPlugins.vim-spl ];
  } ''
    test -f ${vimPlugins.vim-spl}/ftplugin/spl.vim

    touch $out
  '');

  vimwiki-dev-plugin = ifSupported vimPlugins.vimwiki-dev (runCommandNoCC "test-vimwiki-dev-plugin" {
    buildInputs = [ vimPlugins.vimwiki-dev ];
  } ''
    test -f ${vimPlugins.vimwiki-dev}/plugin/vimwiki.vim

    touch $out
  '');

  vim-zeek-plugin = ifSupported vimPlugins.vim-zeek (runCommandNoCC "test-vim-zeek-plugin" {
    buildInputs = [ vimPlugins.vim-zeek ];
  } ''
    test -f ${vimPlugins.vim-zeek}/ftplugin/zeek.vim

    touch $out
  '');

  oscpy-import = ifSupported python3Packages.oscpy (runCommandNoCC "test-oscpy-import" {
    buildInputs = [ python3 python3Packages.oscpy ];
  } ''
    python3 -c 'import oscpy'

    touch $out
  '');
}
