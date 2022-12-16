{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    disko = {
      # TODO: temporarily use personal fork
      #url = "github:nix-community/disko";
      url = "github:lilyinstarlight/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-db = {
      url = "github:usertam/nix-index-db/standalone/nixpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    envfs = {
      url = "github:Mic92/envfs";
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

  outputs = { self, nixpkgs, home-manager, sops-nix, impermanence, nix-index-db, nix-alien, envfs, fenix, ... }:
    let
      supportedSystems = with nixpkgs.lib; intersectLists (platforms.x86_64 ++ platforms.aarch64) (platforms.linux ++ platforms.darwin);

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
  {
    lib = {
      foosterosSystem = let
        foosterosSystem = nixpkgs.lib.makeOverridable ({ system ? "x86_64-linux", modules ? [], baseModules ? [], installer ? null }: let
          selfSystem = nixpkgs.lib.nixosSystem {
            system = system;
            specialArgs = {
              inherit self;
              inherit (self) inputs;
            };
            modules = baseModules ++ [
              ./config/base.nix
            ] ++ modules ++ nixpkgs.lib.optionals (installer != null) [
              {
                system.build = let
                  installerConfiguration = foosterosSystem {
                    inherit system baseModules;
                    modules = [
                      (nixpkgs.lib.optionalAttrs (selfSystem.config.system.build ? disko) {
                        system.build.installDisko = selfSystem.config.system.build.disko;
                      })
                      {
                        system.build.installHostname = selfSystem.config.networking.hostName;
                        system.build.installClosure = selfSystem.config.system.build.toplevel;
                      }
                      ./config/installer.nix
                      installer
                    ];
                  };
                in {
                  installerSystem = installerConfiguration;
                  installer = installerConfiguration.config.system.build.isoImage;
                };
              }
            ];
          };
        in selfSystem);
      in foosterosSystem;
    };

    legacyPackages = forAllSystems (system: import ./pkgs {
      pkgs = nixpkgs.legacyPackages.${system};
      fenix = fenix.packages.${system};
    });

    packages = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.linkFarmFromDrvs "foosteros-pkgs"
        (nixpkgs.lib.unique (nixpkgs.lib.filter (drv: !drv.meta.unsupported && !drv.meta.unfree && (drv.meta ? dependsUnfree -> !drv.meta.dependsUnfree)) (nixpkgs.lib.collect (drv: nixpkgs.lib.isDerivation drv) self.legacyPackages.${system})));
    });

    overlays.foosteros = (final: prev: import ./pkgs {
      pkgs = prev;
      outpkgs = final;
      fenix = fenix.packages.${final.stdenv.hostPlatform.system};
    });
    overlays.default = self.overlays.foosteros;

    nixosModules.foosteros = { pkgs, ... } @ args: import ./modules/nixos (args // {
      fpkgs = self.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    });
    nixosModules.default = self.nixosModules.foosteros;

    homeManagerModules.foosteros = { pkgs, ... } @ args: import ./modules/home-manager (args // {
      fpkgs = self.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    });
    homeManagerModules.default = self.homeManagerModules.foosteros;

    checks = forAllSystems (system: import ./tests {
      pkgs = nixpkgs.legacyPackages.${system};
      fpkgs = self.legacyPackages.${system};
      inherit self;
      inherit (self) inputs;
    });

    devShells = forAllSystems (system: {
      sops = nixpkgs.legacyPackages.${system}.mkShell {
        sopsPGPKeyDirs = [
          ./keys/hosts
          ./keys/users
        ];
        nativeBuildInputs = [
          sops-nix.packages.${system}.sops-import-keys-hook
        ];
      };
    });

    nixosConfigurations = {
      minimal = self.lib.foosterosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/minimal/configuration.nix
        ];
        installer = ./hosts/minimal/installer.nix;
      };
      bina = self.lib.foosterosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/bina/configuration.nix
        ];
        installer = ./hosts/bina/installer.nix;
      };
      lia = self.lib.foosterosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/lia/configuration.nix
        ];
        installer = ./hosts/lia/installer.nix;
      };
    };
  };
}
