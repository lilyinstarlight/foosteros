#!/usr/bin/env nix-shell
#! nix-shell -i bash -p mix2nix

# Download mix.lock for the tau server from the release
#curl https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/v4.0.0/app/server/erlang/tau/mix.lock >mix.lock
curl https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/81fc2063c99268b0b4218d7b044920195d1d777c/app/server/erlang/tau/mix.lock >mix.lock

mix2nix mix.lock >mix_deps.nix

rm -f mix.lock
