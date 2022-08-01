{ config, lib, pkgs, ... }:

let
  cfg = config.programs.hyfetch;

  jsonFormat = pkgs.formats.json { };
in {
  meta.maintainers = with lib.maintainers; [ lilyinstarlight ];

  options.programs.hyfetch = with lib; {
    enable = mkEnableOption "hyfetch";

    package = mkOption {
      type = types.package;
      default = pkgs.hyfetch;
      defaultText = literalExpression "pkgs.hyfetch";
      description = "The hyfetch package to use.";
    };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      example = literalExpression ''
        {
          preset = "rainbow";
          mode = "rgb";
          color_align = {
            mode = "horizontal";
          };
        }
      '';
      description = "JSON config for HyFetch";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."hyfetch.json".source =
      jsonFormat.generate "hyfetch.json" cfg.settings;
  };
}
