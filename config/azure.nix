{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.azure {
  environment.systemPackages = with pkgs; [
    (ansible.overrideAttrs (attrs: {
      propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    # TODO: re-add azure-cli once it builds again https://hydra.nixos.org/job/nixos/unstable/nixpkgs.azure-cli.x86_64-linux
    #})) ansible-lint azure-cli
    })) ansible-lint
  ];

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".azure"
        ];
      };
    };
  };
}
