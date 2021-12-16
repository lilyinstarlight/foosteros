{ config, lib, pkgs, ... }:

{
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
    interactiveShellInit = let
      nix-index-wrapper = pkgs.writeScript "command-not-found" ''
        #!${pkgs.bash}/bin/bash
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
        command_not_found_handle "$@"
      '';
    in ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      function __fish_command_not_found_handler --on-event fish_command_not_found
          ${nix-index-wrapper} $argv
      end
    '';
  };
}
