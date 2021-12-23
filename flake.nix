{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    # TODO: temporary fix for NixOS/nix#5728
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      # TODO: temporary fix for NixOS/nix#5728
      inputs.poetry2nix.follows = "poetry2nix";
    };

    envfs = {
      # TODO: temporarily use personal fork
      #url = "github:Mic92/envfs";
      url = "github:lilyinstarlight/envfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, nix-ld, nix-alien, envfs, ... }:
    let
      supportedSystems = with nixpkgs.lib; (intersectLists (platforms.x86_64 ++ platforms.aarch64 ++ platforms.i686) platforms.linux) ++ (intersectLists (platforms.x86_64 ++ platforms.aarch64) platforms.darwin);

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      systempkgs = ({ system }: import nixpkgs {
        inherit system;
        overlays = nixpkgs.lib.attrValues self.overlays;
      });
    in
  {
    lib = {
      baseSystem = { system ? "x86_64-linux", modules ? [], baseModules ? [] }: nixpkgs.lib.nixosSystem {
        system = system;
        modules = baseModules ++ [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          nix-ld.nixosModules.nix-ld
          envfs.nixosModules.envfs
          {
            config._module.args = {
              inherit self;
              inherit (self) inputs outputs;
            };
          }
          ./config/base.nix
        ] ++ modules;
      };
    };

    legacyPackages = forAllSystems (system: import ./pkgs {
      pkgs = systempkgs { inherit system; };
      isOverlay = false;
    });

    defaultPackage = forAllSystems (system:
      let
        pkgs = systempkgs { inherit system; };
      in
        pkgs.linkFarmFromDrvs "foosteros-pkgs" (nixpkgs.lib.filter (drv: !drv.meta.unsupported) (nixpkgs.lib.collect (drv: nixpkgs.lib.isDerivation drv) (
          import ./pkgs {
            inherit pkgs;
            allowUnfree = false;
            isOverlay = false;
          })
        ))
    );

    overlays.foosteros = (final: prev: import ./pkgs {
      pkgs = prev;
      outpkgs = final;
      isOverlay = true;
    });
    overlays.nix-alien = nix-alien.overlay;
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
      inherit system;
    });

    nixosConfigurations = {
      minimal = self.lib.baseSystem {
        modules = [
          ./hosts/minimal/configuration.nix
        ];
      };
      bina = self.lib.baseSystem {
        modules = [
          ./hosts/bina/configuration.nix
        ];
      };
    };
  };
}
