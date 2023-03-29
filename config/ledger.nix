{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.ledger {
  environment.systemPackages = with pkgs; [
    hledger
  ];

  home-manager.users.lily = { config, lib, ... }: {
    home.file.".hledger.journal".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/docs/ledger/2023.journal";
  };
}
