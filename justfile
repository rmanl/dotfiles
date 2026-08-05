# Define path to helpers
export HELPERS_PATH := justfile_directory() + "/scripts/helpers.sh"

# Default recipe to display help information
[private]
default:
  @just --list

# Update commonly changing flakes and prep for a rebuild
[private]
rebuild-pre:
  just update-nix-secrets
  @git add --intent-to-add .

# Run post-rebuild checks, like if sops is running properly afterwards
[private]
rebuild-post: check-sops

# Run a flake check on the config and installer
[group("checks")]
check ARGS="":
	NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}}
	cd installer && NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}}

[private]
_rebuild:
  @just rebuild-pre
  @# NOTE: Add --option eval-cache false if you end up caching a failure you can't get around
  @scripts/rebuild.sh

# Rebuild the system
[group("building")]
rebuild: && rebuild-post
  @just _rebuild

# Rebuild the system and run a flake check
[group("building")]
rebuild-full: && rebuild-post
  @just _rebuild
  @just check

# Update and then rebuild
[group("building")]
upgrade: update rebuild

# Test configuration without building
[group("building")]
test:
  scripts/system-flake-test.sh

# Rebuild the system for reboot
[group("building")]
boot:
  scripts/rebuild-boot.sh

# View journalctl log
[group("building")]
log:
  journalctl -xe

# Update all flake inputs or sinlge input when INPUT is specified
[group("update")]
update *INPUT:
  nix flake update {{ INPUT }} --timeout 5

# Update nix-secrets flake
[group("update")]
update-nix-secrets:
  @(cd ../nix-secrets && git fetch && git rebase > /dev/null) || true
  @just update nix-secrets

# Generate a new age key
[group("secrets")]
age-key:
  nix-shell -p age --run "age-keygen"

# Check if sops-nix activated successfully
[group("secrets")]
check-sops:
  scripts/check-sops.sh

# Build an iso image for installing new systems and create a symlink for qemu usage
[group("iso")]
iso:
  # If we dont remove this folder, libvirtd VM doesnt run with the new iso...
  rm -rf result
  nix build --impure .#nixosConfigurations.iso.config.system.build.isoImage && ln -sf result/iso/*.iso latest.iso

# Install the latest iso to a flash drive
[group("iso")]
iso-install DRIVE:
  just iso
  sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{DRIVE}} bs=4M status=progress oflag=sync

# Collect garbage, removes old derivations
[group("misc")]
garbage:
  sudo nix-collect-garbage -d && nix-collect-garbage -d

# List all generations on system
[group("misc")]
list-gen:
  sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Switch to generation
[group("misc")]
switch-gen GEN:
  sudo nix-env --switch-generation {{GEN}} -p /nix/var/nix/profiles/system

# Del generation
[group("misc")]
del-gen GEN: garbage
  sudo nix-env --delete-generations {{GEN}}

#
# ========== Nix-Secrets manipulation recipes ==========
#

# Update sops keys in nix-secrets repo
[group("secrets")]
sops-rekey:
    cd ../nix-secrets && for file in $(ls *.yaml); do \
      sops updatekeys -y $file; \
    done

# Update all keys in *.yaml files in nix-secrets to match the creation rules keys
[group("secrets")]
rekey: sops-rekey
    cd ../nix-secrets && \
      (pre-commit run --all-files || true) && \
      git add -u && (git commit -nm "chore: rekey" || true) && git push

# Update an age key anchor or add a new one
[group("secrets")]
sops-update-age-key FIELD KEYNAME KEY:
    #!/usr/bin/env bash
    source {{ HELPERS_PATH }}
    sops_update_age_key {{ FIELD }} {{ KEYNAME }} {{ KEY }}

# Update an existing user age key anchor or add a new one
[group("secrets")]
sops-update-user-age-key USER HOST KEY:
    just sops-update-age-key users {{ USER }}_{{ HOST }} {{ KEY }}

# Update an existing host age key anchor or add a new one
[group("secrets")]
sops-update-host-age-key HOST KEY:
    just sops-update-age-key hosts {{ HOST }} {{ KEY }}

# Automatically create creation rules entries for a <host>.yaml file for host-specific secrets
[group("secrets")]
sops-add-host-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{ HELPERS_PATH }}
    sops_add_host_creation_rules "{{ USER }}" "{{ HOST }}"

# Automatically create creation rules entries for a shared.yaml file for shared secrets
[group("secrets")]
sops-add-shared-creation-rules USER HOST:
    #!/usr/bin/env bash
    source {{ HELPERS_PATH }}
    sops_add_shared_creation_rules "{{ USER }}" "{{ HOST }}"

# Automatically add the host and user keys to creation rules for shared.yaml and <host>.yaml
[group("secrets")]
sops-add-creation-rules USER HOST:
    just sops-add-host-creation-rules {{ USER }} {{ HOST }} && \
    just sops-add-shared-creation-rules {{ USER }} {{ HOST }}

