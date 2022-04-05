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

    impermanence.url = "github:nix-community/impermanence";

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    envfs = {
      # TODO: temporarily use personal fork
      #url = "github:Mic92/envfs";
      url = "github:lilyinstarlight/envfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, impermanence, nix-alien, envfs, fenix, ... }@inputs:
    let
      supportedSystems = with nixpkgs.lib; (intersectLists (platforms.x86_64 ++ platforms.aarch64 ++ platforms.i686) platforms.linux) ++ (intersectLists (platforms.x86_64 ++ platforms.aarch64) platforms.darwin);

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
  {
    lib = {
      baseSystem = { system ? "x86_64-linux", modules ? [], baseModules ? [] }: nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {
          fpkgs = self.legacyPackages.${system};
          inherit self;
          inherit (self) inputs outputs;
        };
        modules = baseModules ++ [
          ./config/base.nix
        ] ++ modules;
      };
    };

    legacyPackages = forAllSystems (system: import ./pkgs {
      pkgs = nixpkgs.legacyPackages.${system};
      fenix = fenix.packages.${system};
      isOverlay = false;
    });

    packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.linkFarmFromDrvs "foosteros-pkgs" (nixpkgs.lib.unique (nixpkgs.lib.filter (drv: !drv.meta.unsupported) (nixpkgs.lib.collect (drv: nixpkgs.lib.isDerivation drv) (
          import ./pkgs {
            pkgs = nixpkgs.legacyPackages.${system};
            fenix = fenix.packages.${system};
            allowUnfree = false;
            isOverlay = false;
          })
        )));
      }
    );

    overlays.foosteros = (final: prev: import ./pkgs {
      pkgs = prev;
      outpkgs = final;
      fenix = fenix.packages.${final.stdenv.hostPlatform.system};
      isOverlay = true;
    });
    overlays.default = self.overlays.foosteros;

    nixosModules.foosteros = { config, system, ... }: import ./modules/nixos {
      pkgs = nixpkgs.legacyPackages.${system};
      fpkgs = self.legacyPackages.${system};
      inherit self;
      inherit (self) inputs outputs;
      inherit config;
    };
    nixosModules.default = self.nixosModules.foosteros;

    checks = forAllSystems (system: import ./tests {
      pkgs = nixpkgs.legacyPackages.${system};
      fpkgs = self.legacyPackages.${system};
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
