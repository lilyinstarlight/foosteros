{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.builders {
  nix = {
    settings = {
      builders-use-substitutes = true;
    };
    distributedBuilds = true;
    buildMachines = [
      /*
      {
        protocol = "ssh-ng";
        hostName = "eu.nixbuild.net";
        maxJobs = 64;
        systems = [ "x86_64-linux" ];
        supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0=";
        sshUser = "lily";
        sshKey = "/home/lily/.ssh/id_ed25519";
      }
      */
      {
        protocol = "ssh-ng";
        hostName = "aarch64.nixos.community";
        maxJobs = 16;
        systems = [ "aarch64-linux" "armv7l-linux" ];
        supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1VVHo1aTl1NUgyRkhOQW1aSnlvSmZJR3lVbS9IZkdoZnduYzE0MkwzZHM=";
        sshUser = "lily";
        sshKey = "/home/lily/.ssh/id_ed25519";
      }
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
    ];
  };
}
