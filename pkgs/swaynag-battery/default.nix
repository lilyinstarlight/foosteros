{ lib, buildGoModule, fetchFromGitHub, makeWrapper, sway, runCommand }:

let swaynag-battery =
buildGoModule rec {
  pname = "swaynag-battery";
  version = "unstable-2022-05-11";

  src = fetchFromGitHub {
    owner = "m00qek";
    repo = pname;
    #rev = "v${version}";
    rev = "9f9d4143d1b53631b525fe2041ca36cd0678e626";
    hash = "sha256-PWLw1DWoaauHNmOuODsKK9i6dpYnSJMz1uprKMo8SoM=";
  };
  vendorSha256 = "sha256-h9Zj3zmQ0Xpili5Pl6CXh1L0bb2uL1//B79I4/ron08=";

  nativeBuildInputs = [
    makeWrapper
  ];

  fixupPhase = ''
    wrapProgram $out/bin/swaynag-battery \
      --prefix PATH : "${sway}/bin"
  '';

  passthru.tests = {
    # test to make sure executable runs
    help = runCommand "${swaynag-battery.name}-help-test" {} ''
      ${swaynag-battery}/bin/swaynag-battery --help >$out
    '';
  };

  meta = with lib; {
    homepage = "https://github.com/m00qek/swaynag-battery";
    description = "Show a message when battery is low and discharging";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    mainProgram = "swaynag-battery";
  };
}
; in swaynag-battery
