{ nixpkgs ? <nixpkgs>, ... }:

{
  pkgs = import nixpkgs {
    overlays = [
      (self: super: (import ./pkgs/default.nix { pkgs = super; }))
    ];
  };
}
