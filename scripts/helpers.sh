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
