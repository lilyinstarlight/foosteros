{ lib
, buildGoModule
, fetchFromGitHub
, fetchurl
}:

buildGoModule rec {
  pname = "tkey-verification";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-verification";
    rev = "v${version}";
    hash = "sha256-35+r+OxBLb+wF2S7LM4towlxmToe+UtzXP340pR58b0=";
  };

  vendorHash = "sha256-fiFG16njTHbdSXnNtMSjqKdlTtqL3YZRRaPKuKt02xg=";

  subPackages = [ "cmd/tkey-verification" ];

  env = rec {
    # Requires same hash as upstream blob and building ourselves
    # is prohibitively difficult to reproduce bit-for-bit an
    # upstream oci container build.
    VERISIGNER_VERSION = "0.0.3";
    VERISIGNER_BIN = fetchurl {
      # TODO: restore when newer versions have verisigner release asset or tillitis/tkey-verification#19 is merged
      #url = "https://github.com/tillitis/tkey-verification/releases/download/v${version}/verisigner-v${VERISIGNER_VERSION}.bin";
      url = "https://github.com/tillitis/tkey-verification/releases/download/v0.0.2/verisigner-v${VERISIGNER_VERSION}.bin";
      hash = "sha256-g6VNQ1nGjhVjUeCgjZc4U8+BRVAe6F4NfAKB25s4dv0=";
    };
  };

  preConfigure = ''
    mv ./vendor-signing-pubkeys.txt ./internal/vendorsigning/vendor-signing-pubkeys.txt
    cp -r "$VERISIGNER_BIN" "internal/appbins/bins/verisigner-v''${VERISIGNER_VERSION}".bin
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "A tool used for signing a TKey identity and verifying that it still has the same identity as it did when it was produced by Tillitis";
    homepage = "https://github.com/tillitis/tkey-verification";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    sourceProvenance = with sourceTypes; [ fromSource binaryFirmware ];
    mainProgram = "tkey-verification";
  };
}
