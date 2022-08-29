{ python3Packages }:

# TODO: remove whole directory when NixOS/nixpkgs#187636 is merged
rec {
  anyio = python3Packages.callPackage ./anyio {};
  httpcore = python3Packages.callPackage ./httpcore {
    inherit anyio;
  };
  httpx = python3Packages.callPackage ./httpx {
    inherit httpcore;
  };
}
