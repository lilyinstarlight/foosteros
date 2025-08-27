{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.azure {
  environment.systemPackages = with pkgs; [
    # TODO: re-add azure-cli when NixOS/nixpkgs#437525 is fixed
    #(ansible.overrideAttrs (attrs: {
    #  propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    #})) azure-cli
  ];
}
