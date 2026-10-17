{ lib, host }:
lib.concatStringsSep "\n" (
  lib.mapAttrsToList (name: value: "alias ${name}=${lib.escapeShellArg value}") (
    import ./_aliases.nix host
  )
)
