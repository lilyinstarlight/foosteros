{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.tex {
  environment.systemPackages = with pkgs; [
    texliveFull
    (pkgs.writeShellApplication {
      name = "pdflatexmk";
      runtimeInputs = with pkgs; [ texliveFull ];
      text = ''
        latexmk -pdf "$@" && latexmk -c "$@"
      '';
    })
  ];
}
