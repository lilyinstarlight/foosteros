{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, cmake
, pkg-config
, catch2
, qtbase
, qtsvg
, fftwSinglePrec
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
, qwt

# does not quite work due to absolute path of source being compiled in for resource loading
, withImGui ? false
, gl3w
, SDL2
, xorg
, fmt
}:

let

  supercollider_single_prec = supercollider.override { fftw = fftwSinglePrec; };
  kissfft_float = kissfft.override { datatype = "float"; };
  SDL2_static = SDL2.override { withStatic = true; };
  SDL2_staticdeps = with xorg; [
    libX11
    libXext
    libXcursor
    libXinerama
    libXi
    libXrandr
    libXScrnSaver
    libXxf86vm
  ];

in

stdenv.mkDerivation rec {
  version = "4.0.0-beta1";
  pname = "sonic-pi";

  src = fetchFromGitHub {
    owner = "sonic-pi-net";
    repo = pname;
    #rev = "v${version}";
    rev = "cb4a105cd961298ee80af5b84768acd394f657da";
    sha256 = "07yv5f42nqabxy9jbibhl82s6ibz24c4yasmmcw0a2i6fjaax3h8";
  };

  patches = [
    ./sonic-pi-4.0-no-vcpkg.patch
    ./sonic-pi-4.0-fix-lib-dir.patch
    ./sonic-pi-4.0-link-librt.patch
    ./sonic-pi-4.0-fix-jackd-detection.patch
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
    supercollider_single_prec
    boost
  ] ++ lib.optional withImGui ([
    gl3w
    SDL2_static.dev
    fmt.dev
  ] ++ SDL2_staticdeps);

  dontUseCmakeConfigure = true;

  preConfigure = ''
    patchShebangs .
  '' + lib.optionalString (!withImGui) ''
    substituteInPlace app/gui/CMakeLists.txt \
      --replace 'add_subdirectory(imgui)' '#add_subdirectory(imgui)'
  '';

  buildPhase = ''
    export SONIC_PI_HOME=$TMPDIR

    pushd app
      ./linux-prebuild.sh
      ./linux-config.sh
    popd

    pushd app/build
      cmake --build . --config Release
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
    runHook postInstall
  '';

  # $out/bin/sonic-pi is a shell script, and wrapQtAppsHook doesn't wrap them.
  dontWrapQtApps = true;
  preFixup = ''
    wrapQtApp "$out/bin/sonic-pi" \
      --prefix PATH : ${ruby}/bin:${erlang}/bin:${supercollider}/bin:${jack2}/bin
  '';

  meta = {
    homepage = "https://sonic-pi.net/";
    description = "Free live coding synth for everyone originally designed to support computing and music lessons within schools";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
