#!/usr/bin/env bash
# shellcheck disable=SC2086
#
# this script is used to rebuild the system configuration for the current host.
#
# sc2086 is ignored because we purposefully pass some values as a set of arguments, so we want the splitting to happen

# helpers library
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

switch_args="--show-trace --impure --flake "
if [[ -n $1 && $1 == "trace" ]]; then
  switch_args="$switch_args --show-trace "
elif [[ -n $1 ]]; then
  HOST=$1
else
  HOST=$(hostname)
fi
switch_args="$switch_args .#$HOST switch"

green "====== REBUILD ======"
if command -v nh &>/dev/null; then
  REPO_PATH=$PWD
  export REPO_PATH
  nh os switch . -- --impure --show-trace
else
  sudo nixos-rebuild "$switch_args"
fi

# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
  green "====== POST-REBUILD ======"
  green "Rebuilt successfully"

  # check if there are any pending changes that would affect the build succeeding.
  if git diff --exit-code >/dev/null && git diff --staged --exit-code >/dev/null; then
    # check if the current commit has a buildable tag
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
