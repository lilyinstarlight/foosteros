#!/usr/bin/env nix-shell
#! nix-shell -i bash -p mix2nix

# Download mix.lock for the tau server from the release
#curl https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/v4.0.0/app/server/beam/tau/mix.lock >mix.lock
curl https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/a3be7aa88db14933abfb6bd3bbe3238564652729/app/server/beam/tau/mix.lock >mix.lock

mix2nix mix.lock >mix-deps.nix

rm -f mix.lock
