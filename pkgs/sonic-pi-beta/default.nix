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
, alsa-lib
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
  version = "4.0.0-beta2";
  pname = "sonic-pi";

  src = fetchFromGitHub {
    owner = "sonic-pi-net";
    repo = pname;
    #rev = "v${version}";
    rev = "971d3a5b754d65e694369fafb9c425c65fddd2b9";
    sha256 = "sha256-RBwfJyqJZ8JODEcFUyW1YfA+SJV6i3igBARh2lzpWNs=";
  };

  patches = [
    ./sonic-pi-4.0-no-vcpkg.patch
    ./sonic-pi-4.0-no-hex-deps.patch
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
    alsa-lib
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
    # Set build environment
    export SONIC_PI_HOME="$TMPDIR/spi"

    export HEX_HOME="$TEMPDIR/hex"
    export HEX_OFFLINE=1
    export MIX_HOME="$TEMPDIR/mix"
    export MIX_ENV=prod

    # Fix shebangs
    patchShebangs .

    # Link mix2nix dependencies from ERL_LIBS
    mkdir -p app/server/beam/tau/_build/"$MIX_ENV"/lib
    while read -r -d ':' lib; do
        for dir in "$lib"/*; do
          ln -s "$dir" app/server/beam/tau/_build/"$MIX_ENV"/lib/"$(basename "$dir" | cut -d '-' -f1)"
        done
    done <<< "$ERL_LIBS:"
  '';

  buildPhase = ''
    # TODO: tell upstream to fix this
    chmod +x app/server/beam/print_erlang_version app/server/beam/tau/boot-lin.sh app/server/beam/tau/boot-mac.sh

    # Prebuild vendored dependencies and beam server
    pushd app
      ./linux-prebuild.sh
    popd

    # Configure CMake
    mkdir -p app/build
    pushd app/build
      cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DAPP_INSTALL_ROOT="$out/app" -DBUILD_IMGUI_INTERFACE=${if withImGui then "ON" else "OFF"} ..
    popd

    # Build
    pushd app/build
      cmake --build . --config Release
    popd
  '';

  installPhase = ''
    runHook preInstall

    # Copy distributable files
    mkdir $out
    cp -r {bin,etc} $out/

    # Copy server whole
    mkdir -p $out/app
    cp -r app/server $out/app/

    # Copy only necessary files for the Qt GUI
    mkdir -p $out/app/gui/qt
    cp -r app/gui/qt/{book,fonts,help,html,images,image_source,info,lang,theme} $out/app/gui/qt/

    # Copy Qt GUI binary
    mkdir -p $out/app/build/gui/qt
    cp app/build/gui/qt/sonic-pi $out/app/build/gui/qt/sonic-pi

    # If ImGui was built
    if [ -x app/build/gui/imgui/sonic-pi-imgui ]; then
      # Copy ImGui files
      mkdir -p $out/app/gui/imgui/res
      cp -r app/gui/imgui/res/Cousine-Regular.ttf $out/app/gui/imgui/res/

      # Copy ImGui binary
      mkdir -p $out/app/build/gui/imgui
      cp app/build/gui/imgui/sonic-pi-imgui $out/app/build/gui/imgui/sonic-pi-imgui
    fi

    # Copy icon
    install -Dm644 app/gui/qt/images/icon-smaller.png $out/share/icons/hicolor/256x256/apps/sonic-pi.png

    # Link desktop item
    mkdir -p $out/share
    ln -s "${desktopItem}/share/applications" $out/share/applications

    runHook postInstall
  '';

  # $out/bin/sonic-pi is a shell script, and wrapQtAppsHook doesn't wrap them.
  dontWrapQtApps = true;
  preFixup = ''
    # Wrap Tau server boot script
    wrapProgram "$out/app/server/beam/tau/boot-lin.sh" \
      --set MIX_ENV "$MIX_ENV"

    # Wrap Qt GUI (distributed binary)
    wrapQtApp "$out/bin/sonic-pi" \
      --prefix PATH : ${lib.makeBinPath [ ruby elixir supercollider jack2 ]}

    # If ImGui was built
    if [ -x "$out/app/build/gui/imgui/sonic-pi-imgui" ]; then
      # Wrap ImGui into bin
      makeWrapper "$out/app/build/gui/imgui/sonic-pi-imgui" "$out/bin/sonic-pi-imgui" \
        --argv0 "$out/bin/sonic-pi-imgui" \
        --prefix PATH : ${lib.makeBinPath [ ruby elixir supercollider jack2 ]}
    fi
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
