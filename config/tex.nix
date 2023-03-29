{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.tex {
  environment.systemPackages = with pkgs; [
    texlive.combined.scheme-full
    (pkgs.writeShellApplication {
      name = "pdflatexmk";
      runtimeInputs = with pkgs; [ texlive.combined.scheme-full ];
      text = ''
            latexmk -pdf "$@" && latexmk -c "$@"
      '';
    })
  ];
}
