#!/bin/sh
root="$(dirname "$(dirname "$(readlink -f "$0")")")"

if [ ! -d "$HOME/.Playdate Simulator/sdk" ]; then
	echo "Creating SDK and virtual disk in $HOME/.Playdate Simluator/sdk..."
	mkdir -p "$HOME/.Playdate Simulator/sdk"
	for dir in "$root"/sdk/*; do
		if [ "$(basename "$dir")" != "Disk" ]; then
			ln -s "$dir" "$HOME/.Playdate Simulator/sdk/$(basename "$dir")"
		else
			cp -r "$dir" "$HOME/.Playdate Simulator/sdk/$(basename "$dir")"
			chmod -R u=rwX,g=rX,o=rX "$HOME/.Playdate Simulator/sdk/$(basename "$dir")"
		fi
	done
fi

echo "Setting SDK path to $HOME/.Playdate Simluator/sdk..."
if grep -qs "^SDKDirectory=" "$HOME/.Playdate Simulator/Playdate Simulator.ini"; then
	sed -i -e "s#^SDKDirectory=.*\$#SDKDirectory=$HOME/.Playdate Simulator/sdk#" "$HOME/.Playdate Simulator/Playdate Simulator.ini"
else
	echo >"$HOME/.Playdate Simulator/Playdate Simulator.ini"
	sed -i -e "1iSDKDirectory=$HOME/.Playdate Simulator/sdk\n[LastUsed]\nPDXDirectory=$HOME/.Playdate Simulator/sdk/Disk/System/Launcher.pdx/" "$HOME/.Playdate Simulator/Playdate Simulator.ini"
fi

exec "$root"/sdk/bin/PlaydateSimulator "$@"
