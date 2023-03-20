{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (ansible.overrideAttrs (attrs: {
      propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    })) azure-cli
  ];
}
