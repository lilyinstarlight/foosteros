{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hledger
  ];

  home-manager.users.lily = { lib, ... }: let cfg = config.home-manager.users.lily; in {
    home.activation = {
      linkHomeLedger = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ln -sTf $VERBOSE_ARG "$HOME"/.hledger.journal "$HOME"/docs/ledger/2023.journal
      '';
    };
  };
}
