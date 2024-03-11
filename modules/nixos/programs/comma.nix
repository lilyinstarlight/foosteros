{ config, lib, pkgs, ... }:

let
  cfg = config.programs.comma;
in

{
  options.programs.comma = {
    enable = lib.mkEnableOption "comma, a wrapper to run software without installing it";

    package = lib.mkPackageOption pkgs "comma" {} // {
      default = pkgs.comma.override { nix-index-unwrapped = config.programs.nix-index.package; };
      defaultText = lib.literalExpression "pkgs.comma.override { nix-index-unwrapped = config.programs.nix-index.package; }";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    programs.nix-index.enable = true;
  };
}
