{ lib, stdenv, fetchurl, makeWrapper, autoPatchelfHook, dpkg, alsa-lib, curl, avahi, gstreamer, gst-plugins-base, libxcb, libX11, libXcursor, libXext, libXi, libXinerama, libXrandr, libXrender, libXxf86vm, libglvnd, gnome }:

let
  runLibDeps = [
    curl
    avahi
    libxcb
    libX11
    libXcursor
    libXext
    libXi
    libXinerama
    libXrandr
    libXrender
    libXxf86vm
    libglvnd
  ];

  runBinDeps = [
    gnome.zenity
  ];
in

stdenv.mkDerivation rec {
  pname = "kodelife";
  version = "1.0.5.161";

  suffix = {
    x86_64-linux  = "linux-x86_64";
    aarch64-linux = "linux-arm64";
    armv7l-linux  = "linux-armhf";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://hexler.net/pub/kodelife/${pname}-${version}-${suffix}.deb";
    hash = {
      x86_64-linux  = "sha256-5M2tgpF74RmrCLI44RBNXK5t0hMAOHtmcjWu7fypc0U=";
      aarch64-linux = "sha256-6QZ5jCxINCH46GQx+V68FpkIAOIOFw4Kd0tUQTKBRzU=";
      armv7l-linux  = "sha256-eToNjPttY62EzNuRSVvJsHttO6Ux6LXRPRuuIKnvaxM=";
    }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  unpackCmd = "mkdir root; ${dpkg}/bin/dpkg-deb -x $curSrc root";

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    gstreamer
    gst-plugins-base
  ];

  installPhase = ''
    mkdir -p $out
    cp -r usr/share $out/share

    mkdir -p $out/bin
    cp opt/kodelife/KodeLife $out/bin/KodeLife

    wrapProgram $out/bin/KodeLife \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runLibDeps} \
      --prefix PATH : ${lib.makeBinPath runBinDeps}
  '';

  meta = with lib; {
    homepage = "https://hexler.net/kodelife";
    description = "Real-time GPU shader editor";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" "aarch64-linux" "armv7l-linux" ];
    mainProgram = "KodeLife";
  };
}
