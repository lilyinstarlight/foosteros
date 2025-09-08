{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.azure {
  environment.systemPackages = with pkgs; [
    (ansible.overrideAttrs (attrs: {
      propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    })) ansible-lint azure-cli
  ];
}
