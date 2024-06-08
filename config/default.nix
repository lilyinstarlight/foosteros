{ config, lib, pkgs, self, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.disko.nixosModules.disko
    inputs.nix-index-database.nixosModules.nix-index
    inputs.lix-module.nixosModules.default
    inputs.nixos-cosmic.nixosModules.default
    self.nixosModules.foosteros
  ] ++ import ./module-list.nix;

  options = {
    foosteros.profiles = {
      base = lib.mkEnableOption "base FoosterOS/2 Warp profile" // {
        default = true;
      };

      lily = lib.mkEnableOption "lily user profile";

      adb = lib.mkEnableOption "adb profile";

      alien = lib.mkEnableOption "alien profile";

      azure = lib.mkEnableOption "azure profile";

      bluetooth = lib.mkEnableOption "bluetooth profile";

      builders = lib.mkEnableOption "builders profile";

      cad = lib.mkEnableOption "cad profile";

      cosmic = lib.mkEnableOption "cosmic profile";

      ephemeral = lib.mkEnableOption "ephemeral root profile";

      fcitx5 = lib.mkEnableOption "fcitx5 profile";

      fish = lib.mkEnableOption "fish profile" // {
        default = true;
      };

      fonts = lib.mkEnableOption "fonts profile";

      fwupd = lib.mkEnableOption "fwupd profile";

      gc = lib.mkEnableOption "gc profile";

      gnupg = lib.mkEnableOption "gnupg profile";

      grub = lib.mkEnableOption "grub profile";

      hibernate = lib.mkEnableOption "hibernate profile";

      homebins = lib.mkEnableOption "homebins profile";

      hyfetch = lib.mkEnableOption "hyfetch profile";

      installer = lib.mkEnableOption "installer profile";

      ledger = lib.mkEnableOption "ledger profile";

      libvirt = lib.mkEnableOption "libvirt profile";

      lsp = lib.mkEnableOption "lsp profile";

      miracast = lib.mkEnableOption "miracast profile";

      music = lib.mkEnableOption "music profile";

      neovim = lib.mkEnableOption "neovim profile" // {
        default = true;
      };

      networkd = lib.mkEnableOption "networkd profile" // {
        default = !config.foosteros.profiles.networkmanager;
        defaultText = lib.literalExpression "!config.foosteros.profiles.networkmanager";
      };

      networkmanager = lib.mkEnableOption "networkmanager profile";

      nullmailer = lib.mkEnableOption "nullmailer profile";

      pass = lib.mkEnableOption "pass profile";

      pipewire = lib.mkEnableOption "pipewire profile";

      pki = lib.mkEnableOption "pki profile";

      playdate = lib.mkEnableOption "playdate profile";

      podman = lib.mkEnableOption "podman profile";

      printing = lib.mkEnableOption "printing profile";

      production = lib.mkEnableOption "production profile";

      restic = lib.mkEnableOption "restic profile";

      sd-boot = lib.mkEnableOption "sd-boot profile" // {
        default = !config.foosteros.profiles.grub;
        defaultText = lib.literalExpression "!config.foosteros.profiles.grub";
      };

      secureboot = lib.mkEnableOption "secureboot profile";

      sway = lib.mkEnableOption "sway profile";

      sysrq = lib.mkEnableOption "sysrq profile";

      tex = lib.mkEnableOption "tex profile";

      tkey = lib.mkEnableOption "tkey profile";

      tmux = lib.mkEnableOption "tmux profile" // {
        default = true;
      };

      udiskie = lib.mkEnableOption "udiskie profile";

      vps = lib.mkEnableOption "vps profile";

      workstation = lib.mkEnableOption "workstation profile";
    };
  };

  config = {
    home-manager.sharedModules = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      self.homeManagerModules.foosteros
    ];
  };
}
