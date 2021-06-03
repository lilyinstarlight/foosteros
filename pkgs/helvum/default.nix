{ lib, fetchFromGitLab, rustPlatform, pkg-config, clang, llvmPackages, gtk4, glib, pipewire }:

rustPlatform.buildRustPackage rec {
  pname = "helvum";
  version = "git";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "ryuukyu";
    repo = "helvum";
    rev = "24fd54affead16f1ed371935fff2c02ae4a50038";
    sha256 = "0qw0h82p5rvg8q4yc3n9hcqfpp0j90cps6gax3qdm1xzsyqhzmrf";
  };

  cargoSha256 = "0bafr19s00zl51zp5ip1ancwa73yg77s67rm6qy3pp3fr647n8d4";

  nativeBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [
    gtk4
    glib
    pipewire
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib/";

  meta = with lib; {
    homepage = "https://gitlab.freedesktop.org/ryuukyu/helvum";
    description = "GTK-based patchbay for PipeWire";
    license = licenses.gpl3;
  };
}
