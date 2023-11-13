{ config, lib, pkgs, self, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.disko.nixosModules.disko
    inputs.nix-index-database.nixosModules.nix-index
    self.nixosModules.foosteros
  ] ++ import ./module-list.nix;

  options = {
    foosteros.profiles = {
      base = lib.mkEnableOption (lib.mdDoc "base FoosterOS/2 Warp profile") // {
        default = true;
      };

      lily = lib.mkEnableOption (lib.mdDoc "lily user profile");

      adb = lib.mkEnableOption (lib.mdDoc "adb profile");

      alien = lib.mkEnableOption (lib.mdDoc "alien profile");

      azure = lib.mkEnableOption (lib.mdDoc "azure profile");

      bluetooth = lib.mkEnableOption (lib.mdDoc "bluetooth profile");

      builders = lib.mkEnableOption (lib.mdDoc "builders profile");

      cad = lib.mkEnableOption (lib.mdDoc "cad profile");

      ephemeral = lib.mkEnableOption (lib.mdDoc "ephemeral root profile");

      fcitx5 = lib.mkEnableOption (lib.mdDoc "fcitx5 profile");

      fish = lib.mkEnableOption (lib.mdDoc "fish profile") // {
        default = true;
      };

      fonts = lib.mkEnableOption (lib.mdDoc "fonts profile");

      fwupd = lib.mkEnableOption (lib.mdDoc "fwupd profile");

      gc = lib.mkEnableOption (lib.mdDoc "gc profile");

      gnupg = lib.mkEnableOption (lib.mdDoc "gnupg profile");

      grub = lib.mkEnableOption (lib.mdDoc "grub profile");

      hibernate = lib.mkEnableOption (lib.mdDoc "hibernate profile");

      homebins = lib.mkEnableOption (lib.mdDoc "homebins profile");

      hyfetch = lib.mkEnableOption (lib.mdDoc "hyfetch profile");

      installer = lib.mkEnableOption (lib.mdDoc "installer profile");

      ledger = lib.mkEnableOption (lib.mdDoc "ledger profile");

      libvirt = lib.mkEnableOption (lib.mdDoc "libvirt profile");

      lsp = lib.mkEnableOption (lib.mdDoc "lsp profile");

      miracast = lib.mkEnableOption (lib.mdDoc "miracast profile");

      music = lib.mkEnableOption (lib.mdDoc "music profile");

      neovim = lib.mkEnableOption (lib.mdDoc "neovim profile") // {
        default = true;
      };

      networkd = lib.mkEnableOption (lib.mdDoc "networkd profile") // {
        default = !config.foosteros.profiles.networkmanager;
        defaultText = lib.literalExpression "!config.foosteros.profiles.networkmanager";
      };

      networkmanager = lib.mkEnableOption (lib.mdDoc "networkmanager profile");

      nullmailer = lib.mkEnableOption (lib.mdDoc "nullmailer profile");

      pass = lib.mkEnableOption (lib.mdDoc "pass profile");

      pipewire = lib.mkEnableOption (lib.mdDoc "pipewire profile");

      pki = lib.mkEnableOption (lib.mdDoc "pki profile");

      playdate = lib.mkEnableOption (lib.mdDoc "playdate profile");

      podman = lib.mkEnableOption (lib.mdDoc "podman profile");

      printing = lib.mkEnableOption (lib.mdDoc "printing profile");

      production = lib.mkEnableOption (lib.mdDoc "production profile");

      restic = lib.mkEnableOption (lib.mdDoc "restic profile");

      sd-boot = lib.mkEnableOption (lib.mdDoc "sd-boot profile") // {
        default = !config.foosteros.profiles.grub;
        defaultText = lib.literalExpression "!config.foosteros.profiles.grub";
      };

      secureboot = lib.mkEnableOption (lib.mdDoc "secureboot profile");

      sway = lib.mkEnableOption (lib.mdDoc "sway profile");

      sysrq = lib.mkEnableOption (lib.mdDoc "sysrq profile");

      tex = lib.mkEnableOption (lib.mdDoc "tex profile");

      tkey = lib.mkEnableOption (lib.mdDoc "tkey profile");

      tlp = lib.mkEnableOption (lib.mdDoc "tlp profile");

      tmux = lib.mkEnableOption (lib.mdDoc "tmux profile") // {
        default = true;
      };

      udiskie = lib.mkEnableOption (lib.mdDoc "udiskie profile");

      vps = lib.mkEnableOption (lib.mdDoc "vps profile");

      workstation = lib.mkEnableOption (lib.mdDoc "workstation profile");
    };
  };

  config = {
    home-manager.sharedModules = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      self.homeManagerModules.foosteros
    ];
  };
}
