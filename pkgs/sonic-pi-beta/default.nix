{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, makeDesktopItem
, cmake
, pkg-config
, catch2
, qtbase
, qtsvg
, qwt
, kissfft
, crossguid
, reproc
, platform-folders
, ruby
, erlang
, elixir
, beamPackages
, alsaLib
, rtmidi
, boost
, jack2
, supercollider

, withImGui ? false
, gl3w
, SDL2
, fmt
}:

let

  kissfft_float = kissfft.override { datatype = "float"; };

in

stdenv.mkDerivation rec {
  version = "4.0.0-beta1";
  pname = "sonic-pi";

  src = fetchFromGitHub {
    owner = "sonic-pi-net";
    repo = pname;
    #rev = "v${version}";
    rev = "81fc2063c99268b0b4218d7b044920195d1d777c";
    sha256 = "02l3bsilc6jl1q1xv5pzffyj5mfzqx71pnyj5rpangnmbw539ji6";
  };

  patches = [
    ./sonic-pi-4.0-no-vcpkg.patch
    ./sonic-pi-4.0-no-hex-deps.patch
    ./sonic-pi-4.0-fix-elixir-boot.patch
  ] ++ lib.optional withImGui [
    ./sonic-pi-4.0-imgui-app-root.patch
    ./sonic-pi-4.0-imgui-dynamic-sdl2.patch
  ];

  nativeBuildInputs = [
    wrapQtAppsHook
    cmake
    pkg-config
    catch2
  ];

  buildInputs = [
    qtbase
    qtsvg
    qwt
    kissfft_float
    crossguid
    reproc
    platform-folders
    ruby
    erlang
    elixir
    beamPackages.hex
    alsaLib
    rtmidi
    boost
  ]
  ++ lib.attrValues (import ./mix-deps.nix {
    inherit beamPackages lib;
  })
  ++ lib.optional withImGui [
    gl3w
    SDL2.dev
    fmt.dev
  ];

  dontUseCmakeConfigure = true;

  preConfigure = ''
    # TODO: tell upstream to fix this
    mv app/server/erlang/tau/boot.lin.sh app/server/erlang/tau/boot-lin.sh
    chmod +x app/linux-build-all.sh app/server/ruby/bin/daemon.rb app/server/erlang/tau/boot-lin.sh

    # fix shebangs
    patchShebangs .

    # link mix2nix dependencies from ERL_LIBS
    mkdir -p app/server/erlang/tau/_build/prod/lib
    while read -r -d ':' lib; do
        for dir in "$lib"/*; do
          ln -s "$dir" app/server/erlang/tau/_build/prod/lib/"$(basename "$dir" | cut -d '-' -f1)"
        done
    done <<< "$ERL_LIBS:"
  '' + lib.optionalString (!withImGui) ''
    substituteInPlace app/gui/CMakeLists.txt \
      --replace 'add_subdirectory(imgui)' '#add_subdirectory(imgui)'
  '';

  buildPhase = ''
    export SONIC_PI_HOME="$TMPDIR/spi"

    export HEX_HOME="$TEMPDIR/hex"
    export HEX_OFFLINE=1
    export MIX_HOME="$TEMPDIR/mix"
    export MIX_ENV=prod

  '' + (lib.optionalString withImGui ''
    export APP_INSTALL_ROOT="$out/app"

  '') + ''
    pushd app
      ./linux-build-all.sh
    popd
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r {bin,etc} $out/

    # Copy server whole.
    mkdir -p $out/app
    cp -r app/server $out/app/

    # Copy only necessary files for the gui app.
    mkdir -p $out/app/gui/qt
    cp -r app/gui/qt/{book,fonts,help,html,images,image_source,info,lang,theme} $out/app/gui/qt/

    # Copy gui app binary.
    mkdir -p $out/app/build/gui/qt
    cp app/build/gui/qt/sonic-pi $out/app/build/gui/qt/sonic-pi

  '' + (lib.optionalString withImGui ''
    # Copy ImGui files
    mkdir -p $out/app/gui/imgui/res
    cp -r app/gui/imgui/res/Cousine-Regular.ttf $out/app/gui/imgui/res/

    # Copy ImGui binary
    mkdir -p $out/app/build/gui/imgui
    cp app/build/gui/imgui/sonic-pi-imgui $out/app/build/gui/imgui/sonic-pi-imgui

  '') + ''
    # Copy icon
    install -Dm644 app/gui/qt/images/icon-smaller.png $out/share/icons/hicolor/256x256/apps/sonic-pi.png

    # Make desktop item
    mkdir -p "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/applications"

    runHook postInstall
  '';

  # $out/bin/sonic-pi is a shell script, and wrapQtAppsHook doesn't wrap them.
  dontWrapQtApps = true;
  preFixup = ''
    wrapProgram "$out/app/server/erlang/tau/boot-lin.sh" \
      --set MIX_ENV "$MIX_ENV"

    wrapQtApp "$out/bin/sonic-pi" \
      --prefix PATH : ${lib.makeBinPath [ ruby elixir supercollider jack2 ]}
  '' + lib.optionalString withImGui ''

    makeWrapper "$out/app/build/gui/imgui/sonic-pi-imgui" "$out/bin/sonic-pi-imgui" \
      --argv0 "$out/bin/sonic-pi-imgui" \
      --prefix PATH : ${lib.makeBinPath [ ruby elixir supercollider jack2 ]}
  '';

  desktopItem = makeDesktopItem {
    name = "sonic-pi";
    exec = "sonic-pi";
    icon = "sonic-pi";
    desktopName = "Sonic Pi";
    comment = meta.description;
    categories = "Audio;AudioVideo;Education;";
  };

  meta = {
    homepage = "https://sonic-pi.net/";
    description = "Free live coding synth for everyone originally designed to support computing and music lessons within schools";
    license = lib.licenses.mit;
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
