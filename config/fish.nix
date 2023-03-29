{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.fish {
  # TODO: maybe give nushell a try?
  environment.systemPackages = with pkgs; [
    fishPlugins.done
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting ""

      set fish_color_command magenta
      set fish_color_comment brblack
      set fish_color_cwd cyan
      set fish_color_end green
      set fish_color_error red
      set fish_color_escape brblue
      set fish_color_host blue
      set fish_color_operator brblue
      set fish_color_params blue
      set fish_color_quote yellow
      set fish_color_redirection brblue
      set fish_color_user magenta
    '';
    # TODO: maybe try nix-your-shell?
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
}
