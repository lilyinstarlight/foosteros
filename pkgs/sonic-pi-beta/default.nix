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
    rev = "8c718d4de60566873689757ebb9597650e8da885";
    sha256 = "0g6bsii68b3r2f6z56kwh0pi95b2284x3r2azd3mn7y75n6hs299";
  };

  patches = [
    ./sonic-pi-4.0-no-vcpkg.patch
    ./sonic-pi-4.0-fix-lib-dir.patch
    ./sonic-pi-4.0-link-librt.patch
    ./sonic-pi-4.0-fix-jackd-detection.patch
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
    alsaLib
    rtmidi
    boost
  ] ++ lib.optional withImGui [
    gl3w
    SDL2.dev
    fmt.dev
  ];

  dontUseCmakeConfigure = true;

  preConfigure = ''
    chmod +x app/linux-build-all.sh app/server/ruby/bin/daemon.rb  # TODO: tell upstream to fix this
    patchShebangs .
  '' + lib.optionalString (!withImGui) ''
    substituteInPlace app/gui/CMakeLists.txt \
      --replace 'add_subdirectory(imgui)' '#add_subdirectory(imgui)'
  '';

  buildPhase = ''
    export SONIC_PI_HOME=$TMPDIR

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
    wrapQtApp "$out/bin/sonic-pi" \
      --prefix PATH : ${lib.makeBinPath [ ruby erlang supercollider jack2 ]}
  '' + lib.optionalString withImGui ''

    makeWrapper "$out/app/build/gui/imgui/sonic-pi-imgui" "$out/bin/sonic-pi-imgui" \
      --argv0 "$out/bin/sonic-pi-imgui" \
      --prefix PATH : ${lib.makeBinPath [ ruby erlang supercollider jack2 ]}
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
