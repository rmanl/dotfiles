{
  flake.nixosModules.officeZathura =
    {
      host,
      inputs,
      pkgs,
      ...
    }:
    let
      inherit (host) colorTheme userName;
    in
    {
      hjem.users.${userName} = {
        packages = [ pkgs.zathura ];
        files.".config/zathura/zathurarc".source = "${inputs.themes}/extra/zathura/${colorTheme}.zathurarc";
      };
    };
}
