#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

# Download package.json from the release
curl https://raw.githubusercontent.com/jean-emmanuel/open-stage-control/v1.9.9/package.json | grep -v '"electron"\|"electron-installer-debian"\|"electron-packager"\|"electron-packager-plugin-non-proprietary-codecs-ffmpeg"' >package.json

node2nix \
  --node-env ../node-packages/node-env.nix \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix

rm -f package.json
