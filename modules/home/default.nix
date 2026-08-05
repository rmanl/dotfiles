{ flake, ... }:
{
  imports = flake.lib.importModules { dir = ./.; };
}
