#!/usr/bin/env bash
# shellcheck disable=SC2086
# sc2086: some values are intentionally word-split into argument sets

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

switch_args="--show-trace --impure --flake "
if [[ -n $1 && $1 == "trace" ]]; then
  switch_args="$switch_args --show-trace "
  HOST=$(hostname)
elif [[ -n $1 ]]; then
  HOST=$1
else
  HOST=$(hostname)
fi
switch_args="$switch_args .#$HOST switch"

do_rebuild() {
  if command -v nh &>/dev/null; then
    REPO_PATH=$PWD
    export REPO_PATH
    nh os switch .#"$HOST" -- --impure --show-trace
  else
    sudo nixos-rebuild "$switch_args"
  fi
}

green "====== REBUILD ======"
if do_rebuild; then
  green "====== POST-REBUILD ======"
  green "Rebuilt successfully"

  if git diff --exit-code >/dev/null && git diff --staged --exit-code >/dev/null; then
    if git tag --points-at HEAD | grep -q buildable; then
      yellow "Current commit is already tagged as buildable"
    else
      git tag buildable-"$(date +%Y%m%d%H%M%S)" -m ''
      green "Tagged current commit as buildable"
    fi
  else
    yellow "WARN: There are pending changes that would affect the build succeeding. Commit them before tagging"
  fi
fi
