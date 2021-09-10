{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    petty
  ];

  environment.etc = {
    "petty/pettyrc".text = lib.mkDefault ''
      shell=${pkgs.bashInteractive}/bin/bash
    '';
  };

  users.defaultUserShell = pkgs.petty;

  users.users.root.shell = lib.mkOverride 500 pkgs.bashInteractive;  # 100 is default prio and 1000 is module default prio
}
