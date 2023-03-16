{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (ansible.overrideAttrs (attrs: {
      propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    # TODO: remove once azure-cli is fixed in nixos-unstable
    #})) azure-cli
    }))
  ];
}
