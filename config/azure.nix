{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.azure {
  environment.systemPackages = with pkgs; [
    (ansible.overrideAttrs (attrs: {
      propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    })) #azure-cli
    # TODO: uncomment above when https://github.com/NixOS/nixpkgs/pull/345326 reaches unstable
  ];
}
