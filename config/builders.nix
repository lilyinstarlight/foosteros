{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.builders {
  nix = {
    settings = {
      builders-use-substitutes = true;
    };
    distributedBuilds = true;
    buildMachines = [
      {
        protocol = "ssh-ng";
        hostName = "darwin-build-box.winter.cafe";
        maxJobs = 4;
        systems = [ "aarch64-darwin" "x86_64-darwin" ];
        supportedFeatures = [];
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUIwaW85RTBlWGlESUVIdnNpYlhPeE9QdmVTalVQSXIxUm5OS2JVa3czZkQ=";
        sshUser = "lily";
        sshKey = "/home/lily/.ssh/id_ed25519";
      }
      {
        protocol = "ssh-ng";
        hostName = "eu.nixbuild.net";
        maxJobs = 4;
        systems = [ "aarch64-linux" ];
        supportedFeatures = [ "benchmark" "big-parallel" ];
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0=";
        sshUser = "lily";
        sshKey = "/home/lily/.ssh/id_ed25519";
      }
    ];
  };
}
