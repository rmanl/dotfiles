# CLAUDE.md

## Project

NixOS configuration using flake-parts + import-tree. Hosts: exegol, ferrix, mustafar, scarif.
Home management via hjem (no home-manager).

Separate subflake at `installer/` for bootstrapping new systems via nixos-anywhere.
ISO build target at `modules/hosts/iso/default.nix`, built with `just iso`.

## NixOS module structure

```
modules/nixos/
  core/        # essential config on every host (boot, locale, nix daemon, sops, openssh server, security)
  graphics/    # GPU drivers (nvidia)
  hardware/    # hardware support (backlight, bluetooth, fwupd, pipewire)
  services/    # system services (greetd, power, psd, thermald, thinkfan, udisks)
  system/      # OS-level settings (fonts, lanzaboote, networking, nix/lix config, theming, zramswap)
```

## Home module structure

```
modules/home/
  programs/    # general apps (browsers, nvim, foot, etc.)
  graphical/   # WM companion apps (waybar, fuzzel, gtk, mako, etc.)
  shell/       # terminal environment (zsh, git, btop, etc.)
  wms/         # window manager configs (mango/hyprland)
  gaming/      # gaming
```

## Profile modules

```
modules/profiles/   # composable profiles (desktop, laptop, mango, workstation) layered onto hosts
```

## Checks

```
modules/checks/      # pre-commit config + CI/lint helper scripts
```

## Home directory

Never add `home` to the host attrset. Always derive it inline as `"/home/${host.userName}"` — this matches how it's set in `modules/users/primary/nixos.nix`.

## Host properties

Always use `host.*` from `specialArgs` for host-level properties (`isLaptop`, `isGaming`, `isMinimal`, `hostWM`, etc.). Never use NixOS options or a `hostSpec` module for these — follow the dendritic pattern.

## Destructuring conventions

- `host.*` and `config.*`: only pull fields into `inherit (host) foo bar;` / `inherit (config) foo bar;` when 2+ distinct fields from that source are used in the same scope. A single field used once stays inline (e.g. `host.foo`) — don't introduce a binding for it.
- Never consolidate `inputs.*` this way — keep flake inputs fully qualified (`inputs.nixpkgs`, `inputs.hardware`, etc.) even when a file uses several.
- `config.hjem` always stays fully qualified too, even when it would otherwise qualify for inheriting — keeps every module that reads it back consistent with the `hjem.users.${userName} = { ... }` option-definition style used everywhere else.

## Nixpkgs configuration

Unfree allowlist and `pkgs-unstable` are both defined in `modules/nixos/system/nix/pkgs.nix` (module: `nixPkgs`), included via the `nix` module. Do not create separate unfree modules.

To use unstable packages in any module, add `pkgs-unstable` to the args:
```nix
{ host, pkgs-unstable, ... }:
```

## Creating files — use `new:` with brace expansion

```
new: <dir>/<name>.nix
new: <dir>/<name>/{default.nix, config.nix}
new: <dir>/<name>/{default.nix, _options.nix, <subdir>/{_a.nix, _b.nix}}
```

Paths are relative to `modules/`.

## File patterns

**Single file** — module name = filename stem:
```nix
{
  flake.nixosModules.<name> =
    { host, pkgs, ... }:
    {
      hjem.users.${host.userName} = {
        packages = with pkgs; [ ];
      };
    };
}
```

**Directory with multiple files** — only add `default.nix` when you need an explicit aggregator module (e.g. a dir aggregating two leaf files under one name). If the siblings can just be picked up individually by import-tree, skip `default.nix`. When you do add one, it is the aggregator (module name = dir name), siblings are leaves (module name = `parentDirFilename` camelCase, kebab converted):
```nix
# default.nix (aggregator)
{ self, ... }:
{
  flake.nixosModules.<dirName> =
    { ... }:
    {
      imports = with self.nixosModules; [ <leaf1> <leaf2> ];
    };
}
```

**Underscore files (`_`)** — NOT flake-parts modules, import-tree skips them. Plain attrset `{ }` or list `[ ]`, imported directly by the owning module. Also used for custom package derivations co-located with their only consumer (e.g. `greetd/_pam_fde_boot_pw.nix`).

## Package lists

Use `packages = [ pkgs.foo ];` (dotted form) only for a single-package list. Once a second package is added, switch the whole list to `with pkgs; [ foo bar ];`.

## Adding a new host

Each host needs:
```
modules/hosts/<name>/
  default.nix    # nixosConfigurations + all nixosModules (host<Name>, disko<Name>, hardware<Name>)
  _disko.nix     # { module = ...; } built on modules/hosts/_disks.nix (btrfs/btrfsLuks helpers) — imported by installer and by default.nix
  _hardware.nix  # boot essentials only (no inputs) — imported by installer and by default.nix
```

`default.nix` builds `host` from `modules/hosts/_base.nix` (shared defaults) merged with host-specific overrides (`hostName`, `isLaptop`/`isDesktop`/etc., monitor settings), then defines the three modules as before (`disko<Name> = disko.module`, `hardware<Name>`, `host<Name>`).

The `_disko.nix` and `_hardware.nix` split is required so the `installer/` subflake can import them directly without flake-parts.
Also add the host name to `modules/hosts/_names.nix` — this drives both `installer/flake.nix`'s `nixosConfigurations` and the SSH shortcut config generated by `modules/nixos/system/ssh.nix`.

## Adding a new window manager

Create `modules/home/wms/<name>/` for the WM's package and config, then `modules/profiles/<name>.nix` defining `flake.nixosModules.<name>Wm` (mirror `modules/profiles/mango.nix`). Each WM profile is self-contained — bundle all of that WM's own apps/tools directly in it; there's no shared/agnostic WM profile to split things into.

Naming is strict and load-bearing: the profile's attribute name must be exactly `<hostWM value>Wm`, camelCased from the `hostWM` string. E.g. setting `hostWM = "foo"` requires the profile to define `flake.nixosModules.fooWm`. Host `default.nix` files resolve the profile dynamically via `self.nixosModules."${host.hostWM}Wm"` — a mismatch here fails at eval time with a missing-attribute error, not a silent no-op.

Set `hostWM = "<name>"` on the target host, either as an override in that host's `default.nix` or by changing the default in `modules/hosts/_base.nix`. No host-level import list edits are needed beyond that.

`host.hostWM` is also read directly in a few places that don't need changes when adding a WM: `modules/nixos/services/greetd/default.nix` (execs it directly), `modules/home/graphical/hypridle.nix` (has a WM-specific dpms branch, e.g. `"hyprland"`, that new WMs can add a case for if needed), and `modules/home/shell/zsh/zshrc.nix` (a mango-only IPC keybind that degrades gracefully for other WMs).

`modules/home/graphical/xdg/env.nix` sets `XDG_CURRENT_DESKTOP`/`XDG_SESSION_DESKTOP` to raw `host.hostWM`, which matches upstream convention for mango and sway (both lowercase, per their `wayland-sessions/*.desktop` `DesktopNames=`). Hyprland is the exception: keep `hostWM = "hyprland"` lowercase as usual (its own binary is a lowercase symlink to the real `Hyprland` executable, so exec/profile-lookup/IPC checks all keep working unchanged), but when adding it, change `env.nix` to override just these two vars to `"Hyprland"` for that WM (e.g. `if hostWM == "hyprland" then "Hyprland" else hostWM`) — don't add that branch until Hyprland actually exists in the repo.

## Nvidia driver build failures

If `hardware.nvidia.package` (default `nvidiaPackages.stable`) fails to build after a flake update, find a driver version/hash that builds against the kernel this flake update brought in (check nixos-unstable or an older nixpkgs revision for one confirmed to build against that kernel), and pin it in `modules/nixos/graphics/nvidia/settings.nix`:

```nix
package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  version = "<version>";
  sha256_64bit = "<hash>";
  sha256_aarch64 = "<hash>";
  openSha256 = "<hash>";
  settingsSha256 = "<hash>";
  persistencedSha256 = "<hash>";
};
```

Leave a comment above the pin noting why `stable` failed and against which kernel the pinned version was confirmed to build. On each subsequent flake update, check whether `nvidiaPackages.stable` builds again against the new kernel — if so, comment out the pin (don't delete it) and switch back to `nvidiaPackages.stable`.

## AppArmor on NixOS

Removed from `modules/nixos/core/security/default.nix` (was `security.apparmor.enable` + `killUnconfinedConfinables` + `apparmor-profiles`/`apparmor-utils` packages) because it provided zero real confinement: upstream profiles are written for FHS paths (`/usr/lib/firefox/firefox`, `/opt/brave.com/...`) that don't exist on NixOS, and the shipped `brave`/`firefox` profiles specifically are unconfined no-op stubs regardless. A handful of NixOS *service* modules (`services.transmission`, `murmur`, `miniflux`, `lxc`) do ship real Nix-store-aware profiles via `security.apparmor.policies`, but none cover desktop GUI apps.

Recheck on each new NixOS stable release (26.11, 27.05, ...) whether NixOS-native profile support has extended to desktop apps actually used here (particularly the browsers, `librewolf`/`brave`) — if so, re-add `security.apparmor.enable = true` plus the relevant `security.apparmor.policies` entries.

## Lockdown LSM on NixOS

Removed from `modules/nixos/core/security/default.nix` (was `security.lsm = [ "lockdown" ]`) and `modules/nixos/core/security/_params.nix` (was `lockdown=confidentiality` kernel param) because it was never actually active: none of `linuxPackages`, `linuxPackages_zen`, or `linuxPackages_xanmod_stable` in nixpkgs build with `CONFIG_SECURITY_LOCKDOWN_LSM` set — only `_hardened` kernel variants do, and those are off the table (too restrictive for normal desktop/laptop use). Even if it did activate, lockdown's `confidentiality` mode would block loading the unsigned, out-of-tree Nvidia kernel module used here.

Recheck only if switching to a kernel package that compiles in `CONFIG_SECURITY_LOCKDOWN_LSM` (verify via that kernel's `linux-config-*` derivation) — and confirm it coexists with the Nvidia module (e.g. via module signing through lanzaboote) before re-enabling.

## Committing changes

Never push — the user always pushes themselves.

Commit message conventions:

- New module: `<scope>: add <name>`
- Edit: `<scope>: <what changed>`
- Cross-cutting change: `refactor: <description>`
- Lockfile-only bump: `flake: update inputs`
- Fix for breakage caused by a prior flake update: `flake: fix` (singular) or `flake: fixes` (plural), with a `-` bullet per fix in the body, e.g. `- <scope>: <what changed>, removed/changed upstream in <version>`

`<scope>` is the module's parent dir name (`graphical`, `services`, `hosts`, etc.).

Single-line subject only — no body, unless the user explicitly asks for one, or the commit bundles multiple changes from the same category (e.g. several `refactor` changes) into one commit, in which case use `<category>:` as the subject and a `-` bullet with its own full description per change.

For a commit bundling changes across multiple *different* categories, use a comma-separated category list as the subject, then one entry per category in the body — a single `<category>: <description>` line if that category has one change, or `<category>:` followed by `-` bulleted lines if it has several:
```
<cat>, <cat>, <cat>

<cat>: <description>
<cat>:
- <description>
- <description>
<cat>: <description>
```

Keep every `<description>` concise but clear — a short clause, not a full explanatory sentence.
