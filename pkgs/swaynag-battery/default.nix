{ lib, buildGoModule, fetchFromGitHub, makeWrapper, sway }:

buildGoModule rec {
  pname = "swaynag-battery";
  version = "unstable-2021-10-17";

  src = fetchFromGitHub {
    owner = "m00qek";
    repo = pname;
    #rev = "v${version}";
    rev = "43b31b776a7eed612749a461b50373ac4f23887b";
    sha256 = "sha256-JIEXap17xSa461xt+HzhVpKmf4/h6WQ2JXdoTZ9slVw=";
  };
  vendorSha256 = "sha256-h9Zj3zmQ0Xpili5Pl6CXh1L0bb2uL1//B79I4/ron08=";

  nativeBuildInputs = [
    makeWrapper
  ];

  patchPhase = ''
    substituteInPlace parameters.go \
      --replace 'message:   "You battery is running low. Please plug in a power adapter"' 'message:   "Your battery is running low. Please plug in a power adapter"'
  '';

  fixupPhase = ''
    wrapProgram $out/bin/swaynag-battery \
      --prefix PATH : "${sway}/bin"
  '';

  meta = with lib; {
    homepage = "https://github.com/m00qek/swaynag-battery";
    description = "Show a message when battery is low and discharging";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
