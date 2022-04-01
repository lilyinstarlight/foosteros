#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

node2nix \
  --node-env node-env.nix \
  --nodejs-14 \
  --input node-packages.json \
  --output node-packages.nix \
  --composition composition.nix
