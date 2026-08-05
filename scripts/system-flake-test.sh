#!/usr/bin/env bash

if [ "$1" = "" ]; then
	export HOST=$1
else
	HOST=$(hostname)
	export HOST
fi

sudo nixos-rebuild --impure --flake .#"$HOST" test --show-trace
