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
, qtwebengine
, qwt
, kissfft
, crossguid
, reproc
, platform-folders
, ruby
, erlang
, elixir
, esbuild
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

stdenv.mkDerivation rec {
  version = "4.0.0-beta2";
  pname = "sonic-pi";

  src = fetchFromGitHub {
    owner = "sonic-pi-net";
    repo = pname;
    #rev = "v${version}";
    rev = "3959d0e5924f58af9fb174036891e233d677b767";
    sha256 = "sha256-Uu+MeKZ0aF+5gVZowGEGucusuEkuLZmC6btM8ycZXS8=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit version;
    pname = "mix-deps-${pname}";
    src = "${src}/app/server/beam/tau";
    sha256 = "sha256-0wZTPMp3VyX0VCbSaI+a561cFk8i43G/tS8ZiK9EwNQ=";
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
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtwebengine
    qwt
    kissfft
    catch2
    crossguid
    reproc
    platform-folders
    ruby
    erlang
    elixir
    esbuild
    beamPackages.hex
    beamPackages.rebar3
    alsa-lib
    rtmidi
    boost
  ]
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
    export MIX_REBAR="${beamPackages.rebar}/bin/rebar"
    export MIX_REBAR3="${beamPackages.rebar3}/bin/rebar3"
    export REBAR_GLOBAL_CONFIG_DIR="$TEMPDIR/rebar3"
    export REBAR_CACHE_DIR="$TEMPDIR/rebar3.cache"
    export MIX_ESBUILD_PATH="${esbuild}/bin/esbuild"
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

    # Copy example configs
    mkdir -p $out/app
    cp -r app/config $out/app/

    # Copy server natives
    mkdir -p $out/app/server
    cp -r app/server/native $out/app/server/

    # Copy Spider (Ruby) server
    mkdir -p $out/app/server
    cp -r app/server/ruby $out/app/server/

    # Copy built Tau (BEAM) server
    mkdir -p $out/app/server/beam/tau
    cp -r app/server/beam/tau/{_build,boot-lin.sh} $out/app/server/beam/tau/

    # Copy only necessary files for the Qt GUI
    mkdir -p $out/app/gui/qt
    cp -r app/gui/qt/theme $out/app/gui/qt/

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
    # Wrap Qt GUI (distributed binary)
    wrapQtApp $out/bin/sonic-pi \
      --prefix PATH : ${lib.makeBinPath [ ruby supercollider jack2 ]}

    # If ImGui was built
    if [ -x $out/app/build/gui/imgui/sonic-pi-imgui ]; then
      # Wrap ImGui into bin
      makeWrapper $out/app/build/gui/imgui/sonic-pi-imgui $out/bin/sonic-pi-imgui \
        --argv0 $out/bin/sonic-pi-imgui \
        --prefix PATH : ${lib.makeBinPath [ ruby supercollider jack2 ]}
    fi

    # Remove non-essential files from vendored Ruby gems
    for file in $out/app/server/ruby/vendor/*/*; do
      if [ "$(basename "$file")" != "lib" ]; then
        rm -r "$file"
      fi
    done

    # Remove unnecessary/sensitive Erlang artifacts
    rm $out/app/server/beam/tau/_build/prod/rel/tau/{releases/COOKIE,bin/tau.bat}

    # Remove runtime Erlang references
    for file in $(grep -FrIl '${erlang}/lib/erlang' $out/app/server/beam/tau); do
      substituteInPlace "$file" --replace '${erlang}/lib/erlang' $out/app/server/beam/tau/_build/prod/rel/tau
    done

    # Strip Erlang BEAMs
    erl -noinput -eval \
      "lists:foreach(fun(F) -> beam_lib:strip(F) end, filelib:wildcard(\"$out/app/server/beam/tau/**/*.beam\"))" \
      -s init stop
  '';

  stripDebugList = [ "app" "bin" ];

  desktopItem = makeDesktopItem {
    name = "sonic-pi";
    exec = "sonic-pi";
    icon = "sonic-pi";
    desktopName = "Sonic Pi";
    comment = meta.description;
    categories = "Audio;AudioVideo;Education;";
  };

  meta = with lib; {
    homepage = "https://sonic-pi.net/";
    description = "Free live coding synth for everyone originally designed to support computing and music lessons within schools";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
  };
}
