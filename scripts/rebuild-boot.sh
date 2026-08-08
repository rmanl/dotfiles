#!/usr/bin/env bash
set -euo pipefail

if [[ -n ${1-} ]]; then
  HOST=$1
else
  HOST=$(hostname)
fi

sudo nixos-rebuild --impure --flake .#"$HOST" boot
