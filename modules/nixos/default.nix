{ fpkgs, ... }:

{
  imports = import ./module-list.nix;

  config._module.args = { inherit fpkgs; };
}
