#!/usr/bin/env bash

sops_running=$(journalctl --no-pager --no-hostname --since "10 minutes ago" | rg "Starting sops-nix activation")
if [ "$sops_running" = "" ]; then
  exit 0
fi

sops_result=$(journalctl --no-pager --no-hostname --since "10 minutes ago" |
  tac |
  awk '!flag; /Starting sops-nix activation/{flag = 1};' |
  tac |
  rg sops)

if [[ ! $sops_result =~ "Finished sops-nix activation" ]]; then
  echo "ERROR: sops-nix failed to activate"
  echo "ERROR: $sops_result"
  exit 1
fi

exit 0
