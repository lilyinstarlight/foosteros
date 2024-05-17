{
  inputs = {
    ## nixpkgs inputs

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";


    ## foosteros inputs

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.pre-commit-hooks-nix.follows = "pre-commit-hooks";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-index-database.follows = "nix-index-database";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };

    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix";
      flake = false;
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flakey-profile.follows = "flakey-profile";
    };


    ## transitive inputs

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
      inputs.flake-compat.follows = "flake-compat";
      inputs.gitignore.follows = "gitignore";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flakey-profile.url = "github:lf-/flakey-profile";


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

  outputs = { self, nixpkgs, sops-nix, ... }:
    let
      supportedSystems = with nixpkgs.lib; intersectLists (platforms.x86_64 ++ platforms.aarch64) (platforms.linux ++ platforms.darwin);

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
  {
    lib = {
      foosterosSystem = let
        foosterosSystem = nixpkgs.lib.makeOverridable ({ modules ? [], baseModules ? [], installer ? null }: let
          selfSystem = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit self;
              inherit (self) inputs;
            };
            modules = baseModules ++ [
              self.nixosModules.config
            ] ++ modules ++ nixpkgs.lib.optionals (installer != null) [
              ({ pkgs, ... }: {
                system.build = let
                  installerConfiguration = foosterosSystem {
                    inherit baseModules;
                    modules = [
                      {
                        nixpkgs.hostPlatform = selfSystem.config.nixpkgs.hostPlatform;
                        nixpkgs.buildPlatform = selfSystem.config.nixpkgs.buildPlatform;
                      }
                      (nixpkgs.lib.optionalAttrs (selfSystem.config.system.build ? diskoScript) {
                        system.build.installDiskoScript = selfSystem.config.system.build.diskoScript;
                      })
                      {
                        system.build.installHostname = selfSystem.config.networking.hostName;
                        system.build.installClosure = selfSystem.config.system.build.toplevel;
                      }
                      self.nixosModules.installer
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
        (nixpkgs.lib.unique (nixpkgs.lib.filter (drv: drv.meta ? position && !drv.meta.unsupported && !drv.meta.broken && !drv.meta.unfree && (drv ? dependsUnfree -> !drv.dependsUnfree)) (nixpkgs.lib.collect (drv: nixpkgs.lib.isDerivation drv) self.legacyPackages.${system})));

      deploy = nixpkgs.legacyPackages.${system}.writeText "cachix-deploy.json" (builtins.toJSON {
        agents = (nixpkgs.lib.mapAttrs (host: cfg: cfg.config.system.build.toplevel) (nixpkgs.lib.filterAttrs (host: cfg:
          cfg ? config && cfg.config ? system && cfg.config.system ? build && cfg.config.system.build ? toplevel && cfg.pkgs.stdenv.buildPlatform.system == system && cfg.config.services.cachix-agent.enable) self.nixosConfigurations));
      });
    });

    overlays = {
      foosteros = (final: prev: import ./pkgs {
        pkgs = prev;
        outpkgs = final;
      });

      default = self.overlays.foosteros;
    };

    nixosModules = {
      foosteros = { pkgs, ... } @ args: import ./modules/nixos (args // {
        fpkgs = self.lib.packagesFor pkgs;
      });

      config = import ./config;
      installer = import ./installer;

      default = self.nixosModules.foosteros;
    };

    homeManagerModules = {
      foosteros = { pkgs, ... } @ args: import ./modules/home-manager (args // {
        fpkgs = self.lib.packagesFor pkgs;
      });

      default = self.homeManagerModules.foosteros;
    };

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
        modules = [
          ./hosts/minimal/configuration.nix
        ];
        installer = {};
      };
      bina = self.lib.foosterosSystem {
        modules = [
          ./hosts/bina/configuration.nix
        ];
        installer = {};
      };
      lia = self.lib.foosterosSystem {
        modules = [
          ./hosts/lia/configuration.nix
        ];
        installer = {};
      };
    };
  };
}
