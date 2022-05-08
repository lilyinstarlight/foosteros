{ lib, buildGoModule, fetchFromGitHub, fetchpatch, makeWrapper, sway, runCommand }:

let swaynag-battery =
buildGoModule rec {
  pname = "swaynag-battery";
  version = "unstable-2022-05-07";

  src = fetchFromGitHub {
    owner = "m00qek";
    repo = pname;
    #rev = "v${version}";
    rev = "fb413593363ec5fc9bfe508cf28dfb8ce95707f3";
    hash = "sha256-TY5rUezGmkD4VYAvHpHhRm91rzxd7hFEgSSw8io7DuM=";
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
