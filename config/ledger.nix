{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hledger
  ];

  home-manager.users.lily = { lib, ... }: {
    home.activation = {
      linkHomeLedger = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ln -sTf $VERBOSE_ARG "$HOME"/docs/ledger/2023.journal "$HOME"/.hledger.journal
      '';
    };
  };
}
