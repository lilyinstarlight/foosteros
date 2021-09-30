#!/usr/bin/env nix-shell
#! nix-shell -i bash -p mix2nix

# Download mix.lock for the tau server from the release
#curl https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/v4.0.0/app/server/beam/tau/mix.lock >mix.lock
curl https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/2831982d43298716a27fffc027dbf28147b535e0/app/server/beam/tau/mix.lock >mix.lock

mix2nix mix.lock >mix-deps.nix

rm -f mix.lock
