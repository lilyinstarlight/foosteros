{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.ledger {
  environment.systemPackages = with pkgs; [
    hledger
  ];

  home-manager.users.lily = { config, lib, ... }: {
    home.activation = {
      linkHomeLedger = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ln -sTf $VERBOSE_ARG "$HOME"/docs/ledger/2024.journal "$HOME"/.hledger.journal
      '';
    };
  };
}
