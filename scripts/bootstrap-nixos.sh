#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

target_hostname=""
target_destination=""
target_user=${BOOTSTRAP_USER-$(whoami)}
ssh_port=${BOOTSTRAP_SSH_PORT-22}
ssh_key=${BOOTSTRAP_SSH_KEY-}
luks_passphrase="password"
git_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "${git_root}")

temp=$(mktemp -d)

function cleanup() {
  rm -rf "$temp"
}
trap cleanup exit

function sync() {
  # $1 = user, $2 = source, $3 = destination
  rsync -av --filter=':- .gitignore' -e "ssh -oControlMaster=no -l $1 -oport=${ssh_port}" "$2" "$1@${target_destination}:"
}

function help_and_exit() {
  echo
  echo "Remotely installs NixOS on a target machine using this configuration."
  echo
  echo "USAGE: $0 -n <target_hostname> -d <target_destination> -k <ssh_key> [OPTIONS]"
  echo
  echo "ARGS:"
  echo "  -n <target_hostname>                    specify target_hostname of the target host to deploy the nixos config on."
  echo "  -d <target_destination>                 specify ip or domain to the target host."
  echo "  -k <ssh_key>                            specify the full path to the ssh_key you'll use for remote access to the"
  echo "                                          target during install process."
  echo "                                          Example: -k /home/${target_user}/.ssh/my_ssh_key"
  echo
  echo "OPTIONS:"
  echo "  -u <target_user>                        specify target_user with sudo access, config will be cloned to their home."
  echo "                                          Default='${target_user}'."
  echo "  --port <ssh_port>                       specify the ssh port to use for remote access. Default=${ssh_port}."
  echo "  --debug                                 Enable debug mode."
  echo "  -h | --help                             Print this help."
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -n)
    shift
    target_hostname=$1
    ;;
  -d)
    shift
    target_destination=$1
    ;;
  -u)
    shift
    target_user=$1
    ;;
  -k)
    shift
    ssh_key=$1
    ;;
  --port)
    shift
    ssh_port=$1
    ;;
  --temp-override)
    shift
    temp=$1
    ;;
  --debug)
    set -x
    ;;
  -h | --help) help_and_exit ;;
  *)
    red "ERROR: Invalid option detected."
    help_and_exit
    ;;
  esac
  shift
done

if [ -z "$target_hostname" ] || [ -z "$target_destination" ] || [ -z "$ssh_key" ]; then
  red "ERROR: -n, -d, and -k are all required"
  echo
  help_and_exit
fi

ssh_cmd="ssh \
        -oControlPath=none \
        -oport=${ssh_port} \
        -oForwardAgent=yes \
        -oStrictHostKeyChecking=no \
        -oUserKnownHostsFile=/dev/null \
        -i $ssh_key \
        -t $target_user@$target_destination"
# shellcheck disable=SC2001
ssh_root_cmd=$(echo "$ssh_cmd" | sed "s|${target_user}@|root@|")
scp_cmd="scp -oControlPath=none -oport=${ssh_port} -oStrictHostKeyChecking=no -i $ssh_key"

git_root=$(git rev-parse --show-toplevel)

generated_hardware_config=0
function nixos_anywhere() {
  green "Wiping known_hosts of $target_destination"
  sed -i "/$target_hostname/d; /$target_destination/d" ~/.ssh/known_hosts

  green "Installing NixOS on remote host $target_hostname at $target_destination"

  green "Preparing a new ssh_host_ed25519_key pair for $target_hostname."
  install -d -m755 "$temp/etc/ssh"

  ssh-keygen -t ed25519 -f "$temp/etc/ssh/ssh_host_ed25519_key" -C "$target_user"@"$target_hostname" -N ""
  chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

  green "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
  ssh-keyscan -p "$ssh_port" "$target_destination" | grep -v '^#' >>~/.ssh/known_hosts || true

  cd installer
  if no_or_yes "Manually set luks encryption passphrase? (Default: \"$luks_passphrase\")"; then
    blue "Enter your luks encryption passphrase:"
    read -rs luks_passphrase
    $ssh_root_cmd "/bin/sh -c 'echo $luks_passphrase > /tmp/disko-password'"
  else
    green "Using '$luks_passphrase' as the luks encryption passphrase. Change after installation."
    $ssh_root_cmd "/bin/sh -c 'echo $luks_passphrase > /tmp/disko-password'"
  fi
  if no_or_yes "Generate a new hardware config for this host? Yes if your config doesn't have an entry for this host."; then
    green "Generating hardware-configuration.nix on $target_hostname and adding it to the local config."
    $ssh_root_cmd "nixos-generate-config --no-filesystems --root /mnt"
    $scp_cmd root@"$target_destination":/mnt/etc/nixos/hardware-configuration.nix \
      "${git_root}"/modules/hosts/"$target_hostname"/_hardware.nix
    generated_hardware_config=1
  fi

  SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- \
    --ssh-port "$ssh_port" \
    --post-kexec-ssh-port "$ssh_port" \
    --extra-files "$temp" \
    --flake .#"$target_hostname" \
    root@"$target_destination"

  if ! yes_or_no "Has your system restarted and are you ready to continue? (no exits)"; then
    exit 0
  fi

  green "Adding $target_destination's ssh host fingerprint to ~/.ssh/known_hosts"
  ssh-keyscan -p "$ssh_port" "$target_destination" | grep -v '^#' >>~/.ssh/known_hosts || true
  cd - >/dev/null
}

function update_sops_file() {
  key_name=$1
  key_type=$2
  key=$3

  if [ ! "$key_type" == "hosts" ] && [ ! "$key_type" == "users" ]; then
    red "Invalid key type passed to update_sops_file. Must be either 'hosts' or 'users'."
    exit 1
  fi

  local sops_file="${git_root}/../nix-secrets/.sops.yaml"
  local tmp
  tmp=$(mktemp)

  green "Updating nix-secrets/.sops.yaml"

  awk -v key_name="$key_name" -v key_type="$key_type" -v key="$key" '
	BEGIN {
		in_target_list = 0
		inserted_key = 0
		in_age_list = 0
		inserted_alias = 0
	}

	# ---- drop any existing definition line for this anchor (key rotation) ----
	$0 ~ ("&" key_name "( |$)") { next }

	{
		if ($0 ~ ("^  " key_type ":$")) {
			print
			in_target_list = 1
			next
		}

		if (in_target_list) {
			if ($0 ~ /^    - /) {
				print
				next
			} else {
				if (!inserted_key) {
					print "    - &" key_name " " key
					inserted_key = 1
				}
				in_target_list = 0
			}
		}

		if ($0 ~ /^      - age:$/) {
			print
			in_age_list = 1
			next
		}

		if (in_age_list) {
			if ($0 ~ ("\\*" key_name "$")) {
				inserted_alias = 1
			}
			if ($0 ~ /^          - /) {
				print
				next
			} else {
				if (!inserted_alias) {
					print "          - *" key_name
					inserted_alias = 1
				}
				in_age_list = 0
			}
		}

		print
	}

	END {
		if (in_target_list && !inserted_key) {
			print "    - &" key_name " " key
		}
		if (in_age_list && !inserted_alias) {
			print "          - *" key_name
		}
	}
	' "$sops_file" >"$tmp"

  mv "$tmp" "$sops_file"
}

function generate_host_age_key() {
  green "Generating an age key based on the new ssh_host_ed25519_key"

  target_key=$(ssh-keyscan -p "$ssh_port" -t ssh-ed25519 "$target_destination" 2>&1 | grep ssh-ed25519 | cut -f2- -d" ") || {
    red "Failed to get ssh key. Host down or maybe SSH port now changed?"
    exit 1
  }

  host_age_key=$(nix shell nixpkgs#ssh-to-age.out -c sh -c "echo $target_key | ssh-to-age")

  if grep -qv '^age1' <<<"$host_age_key"; then
    red "The result from generated age key does not match the expected format."
    yellow "Result: $host_age_key"
    yellow "Expected format: age10000000000000000000000000000000000000000000000000000000000"
    exit 1
  else
    echo "$host_age_key"
  fi

  green "Updating nix-secrets/.sops.yaml"
  update_sops_file "$target_hostname" "hosts" "$host_age_key"
}

function generate_user_age_key() {
  green "First checking if ${target_hostname} age key already exists"

  secret_file="${git_root}"/../nix-secrets/secrets.yaml

  if [ ! -f "$secret_file" ]; then
    red "Secret file does not exist. Exiting."
    exit 1
  fi

  if ! sops -d --extract '["keys"]["age"]' "$secret_file" >/dev/null ||
    ! sops -d --extract "[\"keys\"][\"age\"][\"${target_user}_${target_hostname}\"]" "$secret_file" >/dev/null 2>&1; then
    green "Age key does not exist. Generating."
    user_age_key=$(nix shell nixpkgs#age -c "age-keygen")
    readarray -t entries <<<"$user_age_key"
    secret_key=${entries[2]}
    public_key=$(echo "${entries[1]}" | rg key: | cut -f2 -d: | xargs)
    key_name="${target_user}_${target_hostname}"
    # shellcheck disable=SC2116,SC2086
    sops --set "$(echo '["keys"]["age"]["'${key_name}'"] "'$secret_key'"')" "$secret_file"
    update_sops_file "$key_name" "users" "$public_key"
  else
    green "Age key already exists for ${target_hostname}"
  fi
}

if [ -z "${target_hostname}" ] || [ -z "${target_destination}" ] || [ -z "${ssh_key}" ]; then
  red "ERROR: -n, -d, and -k are all required"
  echo
  help_and_exit
fi

if yes_or_no "Run nixos-anywhere installation?"; then
  nixos_anywhere
fi

updated_age_keys=0
if yes_or_no "Generate host (ssh-based) age key?"; then
  generate_host_age_key
  updated_age_keys=1
fi

if yes_or_no "Generate user age key?"; then
  generate_user_age_key
  updated_age_keys=1
fi

if [[ $updated_age_keys == 1 ]]; then
  just rekey
  green "Updating flake input to pick up new .sops.yaml"
  nix flake update nix-secrets
fi

if yes_or_no "Do you want to copy your full config and nix-secrets to $target_hostname?"; then
  green "Adding ssh host fingerprint at $target_destination to ~/.ssh/known_hosts"
  ssh-keyscan -p "$ssh_port" "$target_destination" 2>/dev/null | grep -v '^#' >>~/.ssh/known_hosts || true
  green "Copying full ${repo_name} to $target_hostname"
  sync "$target_user" "${git_root}"
  green "Copying full nix-secrets to $target_hostname"
  sync "$target_user" "${git_root}/../nix-secrets"

  if no_or_yes "Do you want to rebuild immediately?"; then
    green "Rebuilding ${repo_name} on $target_hostname"
    $ssh_cmd "cd ${repo_name} && sudo nixos-rebuild --impure --show-trace --flake .#$target_hostname switch"
  fi
else
  echo
  green "NixOS was successfully installed!"
  echo "Post-install config build instructions:"
  echo "To copy ${repo_name} from this machine to the $target_hostname, run the following command"
  echo "just sync $target_user $target_destination"
  echo "To rebuild, sign into $target_hostname and run the following command"
  echo "cd ${repo_name}"
  echo "sudo nixos-rebuild --show-trace --flake .#$target_hostname switch"
  echo
fi

if [[ $generated_hardware_config == 1 ]]; then
  if yes_or_no "Do you want to commit and push the generated hardware-configuration.nix for $target_hostname to ${repo_name}?"; then
    (pre-commit run --all-files 2>/dev/null || true) &&
      git add "${git_root}/modules/hosts/$target_hostname/_hardware.nix" &&
      (git commit -m "feat: hardware-configuration.nix for $target_hostname" || true) &&
      git push
  fi
fi

green "Success!"
