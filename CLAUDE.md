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

Always use `host.*` from `specialArgs` for host-level properties (`isLaptop`, `isGaming`, `isMinimal`, `wm`, etc.). Never use NixOS options or a `hostSpec` module for these — follow the dendritic pattern.

## Swappable app identities (`_apps.nix`)

`modules/hosts/_apps.nix` centralizes every swappable app choice (terminal, browser, launcher, etc.) as a `host.*` property, so switching apps only requires editing `_apps.nix` — never the consuming modules. Built via a `mkApp` helper:

```nix
mkApp = spec:
  if builtins.isString spec
  then { name = spec; appId = spec; __toString = self: self.name; }
  else { name = spec.name; appId = spec.appId or spec.name; __toString = self: self.name; };
```

Each property is either a bare string (name and appId are the same, e.g. `<prop> = "<binary>";`) or `{ name; appId; }` when the app's real Wayland appid/desktop-id differs from its binary name.

The `__toString` coercion means every call site using string interpolation (`"${host.<prop>}"`) needs no changes — it resolves to `.name` automatically. This does **not** apply to dynamic attribute-path syntax (`foo.${host.<prop>}`) — force it through a quoted interpolation instead (`foo."${host.<prop>}"`). Only sites that need the desktop-identity label (window-rule `appid:` matches, mime/desktop handler keys) use `.appId` explicitly.

**Adding a property**: only promote an app to `_apps.nix` if its identity is referenced (outside its own package declaration) in 2+ files — that's the actual bar, not "is this an app." A single-file-only reference stays a plain hardcoded value where it's used (e.g. gaming apps in `rules.nix` — each only has one reference, inside the `isGaming`-gated window-rule block). Package declarations (`pkgs.<name>`) always stay hardcoded, regardless of whether the identity itself is promoted.

**Changing an app**: edit the value in `_apps.nix`. If it uses the `{ name; appId; }` form, verify the new app's real appid first — check live via `mmsg get all-clients` while it's running, or a `.desktop` file's `StartupWMClass=` field for XWayland apps.

## Monitor configuration (`_monitors.nix`)

Each host defines its monitor as a single structured `host.monitor` value instead of a WM-specific syntax string, built via a `mkMonitor` helper in `modules/hosts/_monitors.nix` (mirrors the `_disks.nix`/`_disko.nix` split — a generic cross-host helper imported directly by each host's own `default.nix`, not merged in automatically like `_apps.nix`, since a monitor spec is unique per host). `mkMonitor` takes `{ name; width; height; refresh; x ? 0; y ? 0; scale ? 1; vrr ? false; }` and fills in defaults for the optional fields.

Every WM's own module is responsible for rendering `host.monitor`'s fields into that WM's native config syntax — the struct itself stays WM-agnostic. When adding a new WM, write a small renderer local to that WM's own config module (e.g. a `monitorRule` binding that builds a list of fragments and joins them) rather than adding rendering logic to `_monitors.nix` — this keeps `_monitors.nix` pure structured data and keeps each WM's syntax self-contained within its own profile, consistent with "Adding a new window manager" above.

`vrr` is modeled as a plain bool, since every monitor/renderer in the repo so far only needs on/off. If a future WM needs more states (e.g. Hyprland's fullscreen-only VRR mode), or other fields (transform/rotation, HDR, etc.), change `_monitors.nix`'s shape only once that WM actually needs it — don't pre-model capabilities nothing in the repo uses yet.

## Destructuring conventions

- Applies to any attrset being destructured, not just `host.*`/`config.*`: a field becomes a *candidate* for `inherit (x) foo bar;` once there are 2+ distinct fields from that source used in the same scope, OR a single field referenced 2+ times. A single field referenced exactly once stays inline (e.g. `host.foo`) — don't introduce a binding for it.
- Clearing that threshold makes a field a candidate, not a mandate — weigh the actual payoff before adding a binding:
  - **Prefix length**: a short prefix (`wm.`, `cfg.`) repeated only 2x often costs more in added lines than it saves. A longer prefix (`monitor.`, `host.wm.`, `config.colors.`) clearly pays for itself.
  - **Clustering**: fields used right next to each other in one dense block benefit a lot (e.g. the 8-field `hl.monitor`/`monitorrule` renderers). Fields scattered far apart in a large file don't — there's no visual repetition to clean up, even if they technically clear the threshold.
- For a block using many fields (roughly 5+) from one source, or where the source itself is a verbose expression (e.g. `config.users.users.${userName}`), prefer a short named alias over listing every field: `let m = monitor; in ... m.width ...` rather than a long `inherit (monitor) name width height ...;` list. Keep the alias short but meaningful — only shrink it to a single letter when the source's own name is what's being abbreviated for brevity (`monitor` → `m`); don't single-letter a name that's already short and descriptive (keep `user`, not `u`). This still beats `with monitor;`, which hides the field's origin entirely and risks silent shadowing. This only applies to a *nested* record whose fields get dot-accessed repeatedly within one isolated block (e.g. `monitor`'s 8 fields inside the `hl.monitor`/`monitorrule` render, or `config.users.users.${userName}`'s fields inside a `root` account block). It does NOT apply to the top-level `inherit (host) foo bar ...;`/`inherit (config.theme) foo bar ...;` list every module already has at the top, whose fields are used broadly across the whole file as bare names — that's already the correct, expected form regardless of field count.
- When a source's own sub-fields are independently meaningful identifiers reused standalone in multiple places (e.g. `pkgs.mpvScripts.modernz`), inherit the leaf names directly (`inherit (pkgs.mpvScripts) modernz sponsorblock-minimal ...;`) rather than aliasing the parent — this drops the repeated namespace prefix entirely instead of just shortening it.
- Never consolidate `inputs.*` this way — keep flake inputs fully qualified (`inputs.nixpkgs`, `inputs.hardware`, etc.) even when a file uses several.
- `config.hjem` always stays fully qualified too, even when it would otherwise qualify for inheriting — keeps every module that reads it back consistent with the `hjem.users.${userName} = { ... }` option-definition style used everywhere else. This exception is narrow: it does not extend to `userName` itself at that same call site — whether `hjem.users.${...}` uses `host.userName` or an already-inherited bare `userName` still just follows the normal threshold rule for that file, since `userName` (unlike `hjem`) is reused too commonly elsewhere to force one spelling at a single call site without creating more within-file inconsistency than it removes.
- For a source with no established precedent either way yet (first time destructuring that kind of record), raise it for discussion rather than assuming the default applies.
- A field only ever accessed with a fallback (`foo.bar or default`) is optional — `inherit` throws at eval time if the attribute is missing, so it can't be used for that field. If the guaranteed field it falls back to only clears the normal threshold *because* of that fallback reference (e.g. `spec.name` used twice total: once directly, once inside `spec.appId or spec.name`), that's too marginal to split out — leave both inline (see `modules/hosts/_apps.nix`'s `mkApp`). Only pull the guaranteed field into its own `inherit` if it's independently repeated enough to clear the threshold on its own, without counting the fallback use.
- Minimize `with` outside of package lists (`with pkgs;`/`with lib;`) — prefer `inherit`, or a short alias (`c`/`h` for `config.colors`/`config.colors.withHashtag`, see below) for a dense block. The one standing exception is `imports = with self.nixosModules; [ moduleA moduleB ];` (and the `inputs.hardware.nixosModules` equivalent on hosts with hardware profiles) — this is the established dendritic-pattern idiom across every aggregator file (`modules/profiles/*.nix`, host `default.nix` files, category `default.nix` aggregators) and stays as-is for cross-file readability/consistency, even though it's technically a `with`. It carries little of the ambiguity/shadowing risk that motivates avoiding `with` elsewhere, since these files have no other local bindings a bare module name could collide with.
- `config.colors`/`config.colors.withHashtag` get the short aliases `c`/`h` respectively (documented in `modules/nixos/system/theming/_options.nix`'s usage comment): `c = config.colors;` when a file only needs the raw form, `h = c.withHashtag;` alongside it when a file needs both forms, or `h = config.colors.withHashtag;` alone when a file only ever needs the hashed form. Pick whichever form(s) the file actually needs as the alias target — don't default to aliasing the top-level `config.colors` and dotting `.withHashtag` everywhere if a file only uses the hashed form.

## Nixpkgs configuration

Unfree allowlist and `pkgs-unstable` are both defined in `modules/nixos/system/nix/pkgs.nix` (module: `nixPkgs`), included via the `nix` module. Do not create separate unfree modules.

To use unstable packages in any module, add `pkgs-unstable` to the args:
```nix
{ host, pkgs-unstable, ... }:
```

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

If the new host overrides `system` to a different arch, also add that arch to `systems` in `flake.nix` — otherwise `devShells`/`checks` won't exist for it (the host's own NixOS build is unaffected either way).

## Adding a new window manager

Create `modules/home/wms/<name>/` for the WM's package and config, then `modules/profiles/<name>.nix` defining `flake.nixosModules.<name>Wm` (mirror `modules/profiles/mango.nix`). Each WM profile is self-contained — bundle all of that WM's own apps/tools directly in it; there's no shared/agnostic WM profile to split things into.

Add an entry to `modules/hosts/_wms.nix` keyed by the WM's name: `xdgDesktopName`, `portalBackend`, and optionally `dpmsOnCmd`/`dpmsOffCmd` (templated with `%MONITOR%`, default to `wlopm`) and `startCmd` (defaults to the WM's name) if the WM doesn't support `wlopm` or its exec binary differs from its name.

Naming is strict and load-bearing: the profile's attribute name must be exactly `<name>Wm`, camelCased from the WM's `_wms.nix` key. E.g. an entry named `foo` requires the profile to define `flake.nixosModules.fooWm`. Host `default.nix` files resolve the profile dynamically via `self.nixosModules."${host.wm}Wm"` (`host.wm` coerces to its name via `__toString`) — a mismatch here fails at eval time with a missing-attribute error, not a silent no-op.

Set the target host's WM by overriding `wm = (import ../_wms.nix).<name>;` in that host's `default.nix` (the `_base.nix` default is `mango`). No host-level import list edits are needed beyond that.

`host.wm`'s fields are read directly in a few places that don't need changes when adding a WM, since they're driven generically by `_wms.nix`: `modules/nixos/services/greetd/default.nix` (`wm.startCmd`), `modules/home/graphical/hypridle.nix` (`wm.dpmsOnCmd`/`dpmsOffCmd`), `modules/home/graphical/xdg/env.nix` (`wm.xdgDesktopName`), and `modules/home/graphical/xdg/portal.nix` (`wm.portalBackend`).

`modules/home/graphical/scripts/codex.nix` (the `codex` launcher's "WM binds" submenu) reads `$XDG_CURRENT_DESKTOP` at runtime and generically parses `~/.config/$XDG_CURRENT_DESKTOP/{binds,scratchpads}.conf` (see "Keybind annotation convention" below) — new WMs using that same plain-text bind convention need no changes here. WMs with a native bind-introspection API need an explicit `case` branch added instead of relying on the generic parser.

## Keybind annotation convention

Bind config files use lowercase single-word `# category` headers (`general`, `apps`, `window`, `workspace`, `media`, `scratchpad`), binds grouped contiguously under each, with a trailing lowercase `# description` comment per bind (don't repeat the category name in it). Verify the WM's parser tolerates trailing inline comments before relying on this (confirmed for mango only). Reference: `modules/home/wms/mango/binds.nix`, `scratchpads.nix`.

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

Leave a comment above the pin noting why `stable` failed and against which kernel the pinned version was confirmed to build. The failure is tied to the kernel *version*, not the flavor — e.g. `linuxPackages_xanmod_stable` and `linuxPackages_zen` on the same 7.2.x line both fail identically, while nixpkgs' plain `linuxPackages` (an older/different line) builds fine. Switching kernel flavor is not a fix for this; only a newer kernel line or an upstream driver fix is.

On each subsequent flake update, check both `nvidiaPackages.stable`'s current version and the pinned version against the new kernel. Verify with a real build, not just eval/`nix flake check` — those only instantiate the derivation and won't catch a kernel-module compile failure. Build the open module directly (`nix build .#nixosConfigurations.<host>.pkgs.<kernelPackages>.nvidiaPackages.stable.open`) or run the full `scripts/system-flake-test.sh`. If either version now builds, comment out the pin (don't delete it) and switch `package` back to `nvidiaPackages.stable` — or bump the pin to a newer version if `stable` itself still fails but something newer builds.

## Hyprpicker nixpkgs pin

`modules/home/graphical/scripts/colorpick.nix` pins `hyprpicker` to commit `5c451cb4e9` (2026-09-01) via `overrideAttrs` + `fetchFromGitHub`, instead of using `pkgs.hyprpicker` directly. The latest tagged release (`v0.4.7`, also what `nixpkgs` and `nixpkgs-unstable` both ship) still uses the old `zwlr-screencopy` protocol, which trips an "invalid stride" error on mango; the pinned commit includes an earlier fix that migrates to `ext-image-copy-capture-v1`, which mango supports correctly.

On each flake update, check the `hyprpicker` version in both `nixpkgs#hyprpicker` and `nixpkgs-unstable#hyprpicker` — once either is newer than `0.4.7`, drop the `hyprpickerFixed` override in `colorpick.nix` and point the script at `pkgs.hyprpicker` directly (or `pkgs-unstable.hyprpicker`, per the `pkgs-unstable` convention, if unstable ships it first). Keep the rest of the script (the swatch-icon notification) — that part isn't related to the packaging pin. Once the override is dropped, delete this section.

## Mango nixpkgs-unstable pin

`modules/home/wms/mango/default.nix` installs `mango` from `pkgs-unstable.mango` instead of `pkgs.mango` because it isn't packaged in stable nixpkgs at all yet (confirmed via `nix eval nixpkgs#mango` — no such attribute). Default preference is stable; this is only on unstable because stable has no package to fall back to.

On each flake update, check whether `pkgs.mango` (stable) now exists — if so, and its version is equal to or newer than the currently-installed `pkgs-unstable.mango` version, switch `mango/default.nix` to `pkgs.mango` and drop the `pkgs-unstable` arg from that module. Once switched, delete this section.

## Bottles nixpkgs-unstable pin

`modules/home/gaming/misc.nix` installs `bottles` from `pkgs-unstable.bottles` instead of `pkgs.bottles` because stable nixpkgs (tracking `nixos-26.05`) ships Bottles 63.2, whose connectivity check only pings `repo.usebottles.com` — a domain that's been decommissioned upstream (NXDOMAIN on every resolver). With no reachable check URL, Bottles always reports itself offline and the first-run setup wizard hangs forever on "Loading bottles...". Bottles 67.4 (`nixpkgs-unstable`) fixed this with a 3-URL fallback check (`proxy.usebottles.com`, `github.com`, `cloudflare.com` — any one succeeding counts as online), which resolves correctly.

On each flake update, check `pkgs.bottles`'s version — once it's >= the version that includes the fallback check (67.4 or newer), switch `misc.nix` back to `pkgs.bottles` and drop the `pkgs-unstable` arg from that module. Verify by checking `bottles/backend/utils/connection.py` in that version's source still has the multi-URL `_check_urls` tuple, not just a version-number bump. Once switched, delete this section.

## AppArmor on NixOS

Removed from `modules/nixos/core/security/default.nix` (was `security.apparmor.enable` + `killUnconfinedConfinables` + `apparmor-profiles`/`apparmor-utils` packages) because it provided zero real confinement: upstream profiles are written for FHS paths (`/usr/lib/firefox/firefox`, `/opt/brave.com/...`) that don't exist on NixOS, and the shipped `brave`/`firefox` profiles specifically are unconfined no-op stubs regardless. A handful of NixOS *service* modules (`services.transmission`, `murmur`, `miniflux`, `lxc`) do ship real Nix-store-aware profiles via `security.apparmor.policies`, but none cover desktop GUI apps.

Recheck on each new NixOS stable release (26.11, 27.05, ...) whether NixOS-native profile support has extended to desktop apps actually used here (particularly the browsers, `librewolf`/`brave`) — if so, re-add `security.apparmor.enable = true` plus the relevant `security.apparmor.policies` entries, then delete this section.

## Lockdown LSM on NixOS

Removed from `modules/nixos/core/security/default.nix` (was `security.lsm = [ "lockdown" ]`) and `modules/nixos/core/security/_params.nix` (was `lockdown=confidentiality` kernel param) because it was never actually active: none of `linuxPackages`, `linuxPackages_zen`, or `linuxPackages_xanmod_stable` in nixpkgs build with `CONFIG_SECURITY_LOCKDOWN_LSM` set — only `_hardened` kernel variants do, and those are off the table (too restrictive for normal desktop/laptop use). Even if it did activate, lockdown's `confidentiality` mode would block loading the unsigned, out-of-tree Nvidia kernel module used here.

Recheck only if switching to a kernel package that compiles in `CONFIG_SECURITY_LOCKDOWN_LSM` (verify via that kernel's `linux-config-*` derivation) — and confirm it coexists with the Nvidia module (e.g. via module signing through lanzaboote) before re-enabling. Once re-enabled, delete this section.

## ISO root password

`modules/hosts/iso/default.nix` force-enables `PermitRootLogin = "yes"` and sets root's `initialHashedPassword` to a hardcoded hash checked into the repo (`modules/hosts/_base.nix`). This is intentional: the ISO only ever boots a blank install target with nothing on it yet, so root access at that stage grants nothing of value — it exists purely to bootstrap a new system via nixos-anywhere. Production hosts never use this hash; sops-managed credentials take over once a host is actually installed.

## Root account password

`modules/users/primary/nixos.nix` has root inherit the same `hashedPasswordFile`/`authorizedKeys` as the primary user, rather than disabling the root account outright. This is a non-issue in practice: `PermitRootLogin = "no"` blocks any remote use of it, and the password itself is sops-managed and rotates with the primary user's — it isn't a separate standing credential.

## Waybar workspaces has no occupied/empty state

`modules/home/graphical/waybar/default.nix` uses the `ext/workspaces` module (the Wayland `ext-workspace-v1` protocol), shared across mango and hyprland so both WMs render workspaces the same way without per-WM branching. That protocol only exposes `active`/`urgent`/`hidden` states — no window-count or occupied/empty bit — so waybar can never add an `.empty`-style CSS class to distinguish an empty tag from one with windows. Don't add CSS selectors targeting such a class; they will silently never match.

Getting real per-tag occupancy would require replacing `ext/workspaces` with a `custom/` script module that queries each compositor's own IPC (`mmsg` for mango, `hyprctl` for hyprland, branching like `scripts/codex.nix`'s WM-binds parser does) — a bigger change, not attempted here because the protocol limitation is accepted as a tradeoff for staying WM-agnostic.

## Committing changes

Never push — the user always pushes themselves.

Commit message conventions:

- New module: `<scope>: add <name>`
- Edit: `<scope>: <what changed>`
- Cross-cutting change: `refactor: <description>`
- Lockfile-only bump: `flake: update inputs`
- Fix for breakage caused by a prior flake update: `flake: fix` (singular) or `flake: fixes` (plural), with a `-` bullet per fix in the body, e.g. `- <scope>: <what changed>, removed/changed upstream in <version>`

`<scope>` is normally the module's parent dir name (`graphical`, `services`, `hosts`, etc.). When several changes in the same commit are all about one specific app or feature, even across different parent dirs, use that app/feature name as the category instead of splitting by dir (e.g. `<app>:` grouping a window-rule fix and an unfree-allowlist addition together, rather than separate `wms:`/`system:` entries).

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
