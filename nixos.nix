{ hostname ? builtins.head (builtins.match "[[:space:]]*([^[:space:]]*)[[:space:]]*" (builtins.readFile "/etc/hostname")), configuration ? builtins.getEnv "NIXOS_CONFIG", system ? builtins.currentSystem }:

let
  self = (import (
      let
        lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      in fetchTarball {
        url = "https://git.lix.systems/lix-project/flake-compat/archive/${lock.nodes.${lock.nodes.${lock.root}.inputs.flake-compat}.locked.rev}.tar.gz";
        sha256 = lock.nodes.${lock.nodes.${lock.root}.inputs.flake-compat}.locked.narHash;
      }
    )
    {
      # hack to skip fetchGit when evaluating impurely and get original paths
      src = {
        outPath = ./.;
      };
    }
  ).defaultNix;

  nixosConfig = if configuration == "" then
    self.nixosConfigurations.${hostname} // {
      system = nixosConfig.config.system.build.toplevel;
      inherit (nixosConfig.config.system.build) vm vmWithBootLoader;
    }
  else
    import "${self.inputs.nixpkgs}/nixos" { inherit configuration system; };
in

nixosConfig
