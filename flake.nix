{
  inputs = {
    ## nixpkgs inputs

    # TODO: remove when NixOS/nixpkgs#208269 is merged
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:lilyinstarlight/nixpkgs/tmp/systemd-initrd-fsck";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";


    ## foosteros inputs

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.crane.follows = "crane";
      inputs.pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };


    ## transitive inputs

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";


    ## misc inputs

    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, impermanence, nix-index-database, nix-alien, ... }:
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
              ({ pkgs, ... }: {
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
                  installer = let
                    isoName = installerConfiguration.config.isoImage.isoName;
                    isoPath = "${installerConfiguration.config.system.build.isoImage}/iso/${isoName}";
                  in pkgs.runCommandLocal isoName { inherit isoPath; } ''ln -s "$isoPath" $out'';
                };
              })
            ];
          };
        in selfSystem);
      in foosterosSystem;

      packagesFor = (pkgs: import ./pkgs { inherit pkgs; });
    };

    legacyPackages = forAllSystems (system: self.lib.packagesFor nixpkgs.legacyPackages.${system});

    packages = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.linkFarmFromDrvs "foosteros-pkgs"
        (nixpkgs.lib.unique (nixpkgs.lib.filter (drv: !drv.meta.unsupported && !drv.meta.unfree && (drv.meta ? dependsUnfree -> !drv.meta.dependsUnfree)) (nixpkgs.lib.collect (drv: nixpkgs.lib.isDerivation drv) self.legacyPackages.${system})));
    });

    overlays.foosteros = (final: prev: import ./pkgs {
      pkgs = prev;
      outpkgs = final;
    });
    overlays.default = self.overlays.foosteros;

    nixosModules.foosteros = { pkgs, ... } @ args: import ./modules/nixos (args // {
      fpkgs = self.lib.packagesFor pkgs;
    });
    nixosModules.default = self.nixosModules.foosteros;

    homeManagerModules.foosteros = { pkgs, ... } @ args: import ./modules/home-manager (args // {
      fpkgs = self.lib.packagesFor pkgs;
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
