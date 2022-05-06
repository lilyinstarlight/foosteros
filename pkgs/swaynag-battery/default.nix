{ lib, buildGoModule, fetchFromGitHub, fetchpatch, makeWrapper, sway, runCommand }:

let swaynag-battery =
buildGoModule rec {
  pname = "swaynag-battery";
  version = "unstable-2022-04-30";

  src = fetchFromGitHub {
    owner = "m00qek";
    repo = pname;
    #rev = "v${version}";
    rev = "ba9f3594e1f051a26bb9964240adc31b90327f9e";
    hash = "sha256-ARkXU0zOcptMlo5947oT0KZvARFNU1DBIEYdue2FzfY=";
  };
  vendorSha256 = "sha256-h9Zj3zmQ0Xpili5Pl6CXh1L0bb2uL1//B79I4/ron08=";

  patches = [
    (fetchpatch {
      name = "swaynag-fix-minor-typo.patch";
      url = "https://github.com/m00qek/swaynag-battery/commit/75250871eab89a06e6623afc608927b996211711.patch";
      hash = "sha256-q0Jb9WD6lCP3hg7SGYOO0wp+ucw5xNA93ib7d3qc5o4=";
    })
  ];

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
