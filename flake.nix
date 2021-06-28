{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
    let
      supportedSystems = with nixpkgs.lib; (intersectLists (platforms.x86_64 ++ platforms.aarch64 ++ platforms.i686 ++ platforms.arm) platforms.linux) ++ (intersectLists (platforms.x86_64 ++ platforms.aarch64) platforms.darwin);

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      systempkgs = ({ system }: import nixpkgs {
        inherit system;
        config.packageOverrides = (pkgs: import ./pkgs { inherit pkgs; });
      });
    in
  {
    legacyPackages = forAllSystems (system: import ./pkgs {
      pkgs = systempkgs { inherit system; };
    });

    nixosModules.foosteros = { config, system, ... }: import ./modules/nixos {
      pkgs = systempkgs { inherit system; };
      inherit (self) inputs;
      inherit config;
    };
    nixosModule = self.nixosModules.foosteros;

    checks = forAllSystems (system: import ./tests {
      pkgs = systempkgs { inherit system; };
      inherit (self) inputs;
    });

    nixosConfigurations = {
      bina = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          { home-manager.extraSpecialArgs.modulesPath = "${self.inputs.home-manager}/modules"; }
          sops-nix.nixosModules.sops
          ./hosts/bina/configuration.nix
        ];
        extraArgs = {
          inherit (self) inputs;
        };
      };
    };
  };
}
