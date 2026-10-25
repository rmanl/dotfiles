#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

if [[ -n ${1-} ]]; then
  HOST=$1
else
  HOST=$(hostname)
fi
export HOST

run_tolerating_flaky_units sudo nixos-rebuild --impure --flake .#"$HOST" test --show-trace
