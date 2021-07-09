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
      supportedSystems = with nixpkgs.lib; (intersectLists (platforms.x86_64 ++ platforms.aarch64 ++ platforms.i686 ++ [ "armv6l-linux" "armv7l-linux" ]) platforms.linux) ++ (intersectLists (platforms.x86_64 ++ platforms.aarch64) platforms.darwin);

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      systempkgs = ({ system }: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
    in
  {
    lib = {
      baseSystem = { system ? "x86_64-linux", modules ? [], extraArgs ? {} }: nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          home-manager.nixosModules.home-manager
          { home-manager.extraSpecialArgs.modulesPath = "${self.inputs.home-manager}/modules"; }
          sops-nix.nixosModules.sops
        ] ++ modules;
        extraArgs = {
          inherit self;
          inherit (self) inputs outputs;
        } // extraArgs;
      };
    };

    legacyPackages = forAllSystems (system: import ./pkgs {
      pkgs = systempkgs { inherit system; };
      isOverlay = false;
    });

    overlays.foosteros = (final: prev: import ./pkgs {
      pkgs = prev;
      outpkgs = final;
    });
    overlay = self.overlays.foosteros;

    nixosModules.foosteros = { config, system, ... }: import ./modules/nixos {
      pkgs = systempkgs { inherit system; };
      inherit self;
      inherit (self) inputs outputs;
      inherit config;
    };
    nixosModule = self.nixosModules.foosteros;

    checks = forAllSystems (system: import ./tests {
      pkgs = systempkgs { inherit system; };
      inherit self;
      inherit (self) inputs outputs;
    });

    nixosConfigurations = {
      bina = self.lib.baseSystem {
        modules = [
          ./hosts/bina/configuration.nix
        ];
      };
    };
  };
}
