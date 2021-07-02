{ pkgs, outputs, ... }:

{
  bina = outputs.nixosConfigurations.bina.config.system.build.toplevel;
}
