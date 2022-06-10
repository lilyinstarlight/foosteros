{ lib, stdenv, fetchurl, makeWrapper, autoPatchelfHook, dpkg, alsa-lib, curl, avahi, jack2, libxcb, libX11, libXcursor, libXext, libXi, libXinerama, libXrandr, libXrender, libXxf86vm, libglvnd, gnome }:

let
  runLibDeps = [
    curl
    avahi
    jack2
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
  pname = "touchosc";
  version = "1.1.3.141";

  suffix = {
    x86_64-linux  = "linux-x86_64";
    aarch64-linux = "linux-arm64";
    armv7l-linux  = "linux-armhf";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://hexler.net/pub/touchosc/${pname}-${version}-${suffix}.deb";
    hash = {
      x86_64-linux  = "sha256-BNGVoL+bSiN987M3nTFGMXVfHVLgiWXmeyfOPnmLR98=";
      aarch64-linux = "sha256-qLBopCzozKhBTqohUd27tQ7VzIqYg7uXxfJBXFQwi7U=";
      armv7l-linux  = "sha256-8lBbikKhIGqFnh8I1JLWBEXkD7SMJoyB99uo0+Wm4hw=";
    }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  unpackCmd = "mkdir root; ${dpkg}/bin/dpkg-deb -x $curSrc root";

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
  ];

  installPhase = ''
    mkdir -p $out
    cp -r usr/share $out/share

    mkdir -p $out/bin
    cp opt/touchosc/TouchOSC $out/bin/TouchOSC

    wrapProgram $out/bin/TouchOSC \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runLibDeps} \
      --prefix PATH : ${lib.makeBinPath runBinDeps}
  '';

  meta = with lib; {
    homepage = "https://hexler.net/touchosc";
    description = "Next generation modular control surface";
    license = licenses.unfree;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" "aarch64-linux" "armv7l-linux" ];
    mainProgram = "TouchOSC";
  };
}
