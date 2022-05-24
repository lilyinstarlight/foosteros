{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.mopidy;

  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-with-extensions-${pkgs.mopidy.version}";
    paths = closePropagation cfg.extensionPackages;
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };

  configFilePaths = concatStringsSep ":"
    ([ "${config.xdg.configHome}/mopidy/mopidy.conf" ] ++ cfg.extraConfigFiles);

in {
  options.services.mopidy = {
    extraConfigFiles = mkOption {
      default = [ ];
      type = types.listOf types.path;
      description = ''
        Extra configuration files read by Mopidy when the service starts.
        Later files in the list override earlier configuration files and
        structured settings.
      '';
    };
  };

  config = mkIf cfg.enable {
    # TODO: remove this entire module once https://github.com/nix-community/home-manager/pull/2970 is merged
    systemd.user.services.mopidy.Service.ExecStart = lib.mkForce "${mopidyEnv}/bin/mopidy --config ${configFilePaths}";
    systemd.user.services.mopidy-scan.Service.ExecStart = lib.mkForce "${mopidyEnv}/bin/mopidy --config ${configFilePaths} local scan";
  };
}
