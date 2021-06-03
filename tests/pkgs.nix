{ pkgs, ... }:

with pkgs;

recurseIntoAttrs {
  oscpy-import = runCommandNoCC "test-oscpy-import" {
    buildInputs = [ python3 python3Packages.oscpy ];
  } ''
    python3 -c 'import oscpy'

    touch $out
  '';
}
