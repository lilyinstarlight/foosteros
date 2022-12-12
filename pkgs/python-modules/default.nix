{ python3Packages }:

# TODO: remove whole directory when NixOS/nixpkgs#205803 is merged
{
  autopep8 = python3Packages.callPackage ./autopep8 {};
}
