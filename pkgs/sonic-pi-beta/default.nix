{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, makeDesktopItem
, copyDesktopItems
, cmake
, pkg-config
, catch2
, qtbase
, qtsvg
, qttools
, qwt
, kissfft
, crossguid
, reproc
, platform-folders
, ruby
, erlang
, elixir
, esbuild
, tailwindcss
, beamPackages
, alsa-lib
, rtmidi
, boost
, jack2
, supercollider-with-sc3-plugins

, withTauWidget ? false
, qtwebengine

, withImGui ? false
, gl3w
, SDL2
, fmt
}:

stdenv.mkDerivation rec {
  version = "4.0.0-beta5";
  pname = "sonic-pi";

  src = fetchFromGitHub {
    owner = "sonic-pi-net";
    repo = pname;
    #rev = "v${version}";
    rev = "930ca7e3f56e11c6859362cb438766f19dcc2598";
    hash = "sha256-9iyz6eZV6Cy9uUiQCyCEkQbfWw0oTZ9RuYBlcooZXOs=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit version;
    pname = "mix-deps-${pname}";
    src = "${src}/app/server/beam/tau";
    sha256 = "sha256-U1O/DqBOnaN97xLECSOLNKn4wVC8V2EqUw023EyN39M=";
  };

  patches = [
    ./sonic-pi-4.0-offline-build.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
    wrapQtAppsHook

    cmake
    pkg-config

    erlang
    elixir
    beamPackages.hex
    beamPackages.rebar3
    esbuild
    tailwindcss
  ];

  buildInputs = [
    qtbase
    qtsvg
    qttools
    qwt
    kissfft
    catch2
    crossguid
    reproc
    platform-folders
    ruby
    alsa-lib
    rtmidi
    boost
  ] ++ (lib.optionals withTauWidget [
    qtwebengine
  ]) ++ (lib.optionals withImGui [
    gl3w
    SDL2
    fmt
  ]);

  dontUseCmakeConfigure = true;

  preConfigure = ''
    # Set build environment
    export SONIC_PI_HOME="$TMPDIR/spi"

    export HEX_HOME="$TEMPDIR/hex"
    export HEX_OFFLINE=1
    export MIX_REBAR3="$(type -p rebar3)"
    export REBAR_GLOBAL_CONFIG_DIR="$TEMPDIR/rebar3"
    export REBAR_CACHE_DIR="$TEMPDIR/rebar3.cache"
    export MIX_ESBUILD_PATH="$(type -p esbuild)"
    export MIX_TAILWINDCSS_PATH="$(type -p tailwindcss)"
    export MIX_HOME="$TEMPDIR/mix"
    export MIX_DEPS_PATH="$TEMPDIR/deps"
    export MIX_ENV=prod

    # Fix shebangs
    patchShebangs .

    # Copy Mix dependency sources
    echo 'Copying ${mixFodDeps} to Mix deps'
    cp --no-preserve=mode -R '${mixFodDeps}' "$MIX_DEPS_PATH"
  '';

  buildPhase = ''
    # Prebuild vendored dependencies and BEAM server
    pushd app
      ./linux-prebuild.sh -o
    popd

    # Configure CMake
    mkdir -p app/build
    pushd app/build
      cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DAPP_INSTALL_ROOT="$out/app" -DUSE_SYSTEM_LIBS=ON -DBUILD_IMGUI_INTERFACE=${if withImGui then "ON" else "OFF"} -DWITH_QT_GUI_WEBENGINE=${if withTauWidget then "ON" else "OFF"} ..
    popd

    # Build
    pushd app/build
      cmake --build . --config Release
    popd
  '';

  installPhase = ''
    runHook preInstall

    # Run Linux release script
    pushd app
      ./linux-release.sh
    popd

    # Copy dist directory to output
    mkdir $out
    cp -r app/build/linux_dist/* $out/

    # Copy icon
    install -Dm644 app/gui/qt/images/icon-smaller.png $out/share/icons/hicolor/256x256/apps/sonic-pi.png

    runHook postInstall
  '';

  # $out/bin/sonic-pi is a shell script, and wrapQtAppsHook doesn't wrap them.
  dontWrapQtApps = true;
  preFixup = ''
    # Wrap Qt GUI (distributed binary)
    wrapQtApp $out/bin/sonic-pi \
      --prefix PATH : ${lib.makeBinPath [ ruby supercollider-with-sc3-plugins jack2 ]}

    # If ImGui was built
    if [ -x $out/app/build/gui/imgui/sonic-pi-imgui ]; then
      # Wrap ImGui into bin
      makeWrapper $out/app/build/gui/imgui/sonic-pi-imgui $out/bin/sonic-pi-imgui \
        --argv0 $out/bin/sonic-pi-imgui \
        --prefix PATH : ${lib.makeBinPath [ ruby supercollider-with-sc3-plugins jack2 ]}
    fi

    # Remove runtime Erlang references
    for file in $(grep -FrIl '${erlang}/lib/erlang' $out/app/server/beam/tau); do
      substituteInPlace "$file" --replace '${erlang}/lib/erlang' $out/app/server/beam/tau/_build/prod/rel/tau
    done
  '';

  stripDebugList = [ "app" "bin" ];

  desktopItems = [
    (makeDesktopItem {
      name = "sonic-pi";
      exec = "sonic-pi";
      icon = "sonic-pi";
      desktopName = "Sonic Pi";
      comment = meta.description;
      categories = [ "Audio" "AudioVideo" "Education" ];
    })
  ];

  meta = with lib; {
    homepage = "https://sonic-pi.net/";
    description = "Free live coding synth for everyone originally designed to support computing and music lessons within schools";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
  };
}
