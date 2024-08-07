{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, qtbase
, qtsvg
, qwt
, ruby
, erlang
, alsa-lib
, rtmidi
, aubio
, cmake
, pkg-config
, boost
, bash
, jack2
, supercollider-with-sc3-plugins
}:

stdenv.mkDerivation rec {
  version = "3.3.1";
  pname = "sonic-pi";

  src = fetchFromGitHub {
    owner = "sonic-pi-net";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-AE7iuSNnW1SAtBMplReGzXKcqD4GG23i10MIAWnlcPo=";
  };

  buildInputs = [
    bash
    cmake
    pkg-config
    qtbase
    qtsvg
    qwt
    ruby
    erlang
    alsa-lib
    rtmidi
    aubio
    boost
  ];

  nativeBuildInputs = [ wrapQtAppsHook ];

  dontUseCmakeConfigure = true;

  preConfigure = ''
    patchShebangs .
    substituteInPlace app/gui/qt/mainwindow.cpp \
      --subst-var-by ruby "${ruby}/bin/ruby" \
      --subst-var out
    substituteInPlace app/external/linux_build_externals.sh --replace \
      'cmake --build . --target aubio' \
      '#cmake --build . --target aubio'
  '';

  buildPhase = ''
    export SONIC_PI_HOME=$TMPDIR
    export AUBIO_LIB=${aubio}/lib/libaubio.so

    mkdir -p app/external/build/aubio-prefix/src/aubio-build
    pushd app/external
      echo 'Building build/aubio-prefix/src/aubio-build/aubio_onset'
      cc -I ${aubio}/include/aubio aubio/examples/aubioonset.c aubio/examples/utils.c -o build/aubio-prefix/src/aubio-build/aubio_onset -l aubio
    popd

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

    runHook postInstall
  '';

  # $out/bin/sonic-pi is a shell script, and wrapQtAppsHook doesn't wrap them.
  dontWrapQtApps = true;
  preFixup = ''
    wrapQtApp "$out/bin/sonic-pi" \
      --prefix PATH : ${lib.makeBinPath [ ruby erlang supercollider-with-sc3-plugins jack2 ]}
  '';

  meta = with lib; {
    homepage = "https://sonic-pi.net/";
    description = "Free live coding synth for everyone originally designed to support computing and music lessons within schools";
    license = licenses.mit;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
  };
}
