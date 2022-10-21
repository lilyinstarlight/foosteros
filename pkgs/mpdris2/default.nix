{ lib, fetchFromGitHub, mpdris2, unstableGitUpdater }:

mpdris2.overrideAttrs (attrs: rec {
  version = "unstable-2022-06-30";

  src = fetchFromGitHub {
    owner = "eonpatapon";
    repo = attrs.pname;
    rev = "55465b8cf6b6b48fb45da43a8579ad335809c99a";
    hash = "sha256-1CkpnVThGfLdevU8ev0KfhIeaBp4ZvhVVn9jjisH1Zs=";
  };

  passthru = (attrs.passthru or {}) // {
    updateScript = unstableGitUpdater {
      # TODO: remove when NixOS/nixpkgs#160453 is merged
      url = src.gitRepoUrl;
    };
  };

  meta = with lib; attrs.meta // {
    inherit (attrs.meta) description;
  };
})
