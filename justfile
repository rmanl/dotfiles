export HELPERS_PATH := justfile_directory() + "/scripts/helpers.sh"

[private]
default:
  @just --list

[private]
rebuild-pre:
  just update-nix-secrets
  @git add --intent-to-add .

[private]
rebuild-post: check-sops

[group("checks")]
check ARGS="":
    NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}}
    [ -d installer ] && cd installer && NIXPKGS_ALLOW_UNFREE=1 REPO_PATH=$(pwd) nix flake check --impure --keep-going --show-trace {{ARGS}} || true

[private]
_rebuild:
  @just rebuild-pre
  @scripts/rebuild.sh

[group("building")]
rebuild: && rebuild-post
  @just _rebuild

[group("building")]
rebuild-full: && rebuild-post
  @just _rebuild
  @just check

[group("building")]
upgrade: update rebuild

[group("building")]
bootstrap *ARGS:
  #!/usr/bin/env bash
  set -euo pipefail
  read -rp "Target hostname: " hostname
  read -rp "Target IP: " ip
  BOOTSTRAP_USER=rma BOOTSTRAP_SSH_PORT=22 BOOTSTRAP_SSH_KEY="$HOME/.ssh/id_rma" scripts/bootstrap-nixos.sh -n "$hostname" -d "$ip" {{ARGS}}

[group("building")]
test:
  scripts/system-flake-test.sh

[group("building")]
boot:
  scripts/rebuild-boot.sh

[group("building")]
log:
  journalctl -xe

[group("update")]
update *INPUT:
  nix flake update {{ INPUT }} --timeout 5

[group("update")]
update-nix-secrets:
  @(cd ../nix-secrets && git fetch && git rebase > /dev/null) || true
  @just update nix-secrets

[group("secrets")]
age-key:
  nix-shell -p age --run "age-keygen"

[group("secrets")]
check-sops:
  scripts/check-sops.sh

[group("iso")]
iso:
  rm -rf result
  nix build --impure .#nixosConfigurations.iso.config.system.build.isoImage && ln -sf result/iso/*.iso nixos_minimal.iso

[group("iso")]
iso-install DRIVE:
  just iso
  sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={{DRIVE}} bs=4M status=progress oflag=sync

[group("misc")]
garbage:
  sudo nix-collect-garbage -d && nix-collect-garbage -d

[group("misc")]
list-gen:
  sudo nix-env --list-generations -p /nix/var/nix/profiles/system

[group("misc")]
switch-gen GEN:
  sudo nix-env --switch-generation {{GEN}} -p /nix/var/nix/profiles/system

[group("misc")]
del-gen GEN: garbage
  sudo nix-env --delete-generations {{GEN}}

# ========== Nix-Secrets ==========

[group("secrets")]
sops-rekey:
    cd ../nix-secrets && for file in $(ls *.yaml); do \
      sops updatekeys -y $file; \
    done

[group("secrets")]
rekey: sops-rekey
    cd ../nix-secrets && \
      (pre-commit run --all-files || true) && \
      git add -u && (git commit -nm "chore: rekey" || true) && git push
