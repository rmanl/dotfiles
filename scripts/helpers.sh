#!/usr/bin/env bash
set -eo pipefail

function red() {
  echo -e "\x1B[31m[!] $1 \x1B[0m"
  if [ "${2-}" != "" ]; then
    echo -e "\x1B[31m[!] $("$2") \x1B[0m"
  fi
}

function green() {
  echo -e "\x1B[32m[+] $1 \x1B[0m"
  if [ "${2-}" != "" ]; then
    echo -e "\x1B[32m[+] $("$2") \x1B[0m"
  fi
}

function blue() {
  echo -e "\x1B[34m[*] $1 \x1B[0m"
  if [ "${2-}" != "" ]; then
    echo -e "\x1B[34m[*] $("$2") \x1B[0m"
  fi
}

function yellow() {
  echo -e "\x1B[33m[*] $1 \x1B[0m"
  if [ "${2-}" != "" ]; then
    echo -e "\x1B[33m[*] $("$2") \x1B[0m"
  fi
}

# ask yes or no, with yes being the default
function yes_or_no() {
  echo -en "\x1B[34m[?] $* [y/n] (default: y): \x1B[0m"
  while true; do
    read -rp "" yn
    yn=${yn:-y}
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    esac
  done
}

# units allowed to fail during nixos-rebuild switch/test without failing the build
KNOWN_FLAKY_UNITS=("ensure-printers.service")

# run a rebuild command, tolerating failures limited to KNOWN_FLAKY_UNITS.
# parses switch-to-configuration's own "warning: the following units
# failed: ..." line, since by the time a unit's Restart= timer fires it may
# no longer show up in `systemctl --failed`.
function run_tolerating_flaky_units() {
  local logfile rc
  logfile=$(mktemp)

  if "$@" 2>&1 | tee "$logfile"; then
    rc=0
  else
    rc=${PIPESTATUS[0]}
  fi

  if [[ $rc -eq 0 ]]; then
    rm -f "$logfile"
    return 0
  fi

  local failed_line
  failed_line=$(grep -m1 "warning: the following units failed:" "$logfile" || true)
  rm -f "$logfile"

  if [[ -z $failed_line ]]; then
    return "$rc"
  fi

  local units_str="${failed_line#*units failed: }"
  local failed=()
  read -ra failed <<<"$units_str"

  local unexpected=()
  for unit in "${failed[@]}"; do
    printf '%s\n' "${KNOWN_FLAKY_UNITS[@]}" | grep -qx "$unit" || unexpected+=("$unit")
  done

  if [[ ${#failed[@]} -gt 0 && ${#unexpected[@]} -eq 0 ]]; then
    yellow "Ignoring known-flaky unit failure(s): ${failed[*]}"
    return 0
  fi
  return "$rc"
}

# ask yes or no, with no being the default
function no_or_yes() {
  echo -en "\x1B[34m[?] $* [y/n] (default: n): \x1B[0m"
  while true; do
    read -rp "" yn
    yn=${yn:-n}
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    esac
  done
}
