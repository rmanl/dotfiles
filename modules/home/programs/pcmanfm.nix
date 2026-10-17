{
  flake.nixosModules.pcmanfm =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (host) userName isMultiDisk isGaming;
      dataPath = if isMultiDisk then "/mnt/data" else "/home/${userName}/data";
    in
    {
      hjem.users.${userName} = {
        packages = [ pkgs.pcmanfm ];

        files = {
          ".config/gtk-3.0/bookmarks".text = lib.concatLines (
            [
              "file:///home/${userName} ${userName}"
              "file:///home/${userName}/.config/dotfiles dotfiles"
              "file:///home/${userName}/downloads downloads"
              "file://${dataPath} data"
            ]
            ++ lib.optional isGaming "file:///mnt/games games"
          );

          ".config/pcmanfm/default/pcmanfm.conf".text = ''
            [config]
            bm_open_method=0

            [volume]
            mount_on_startup=1
            mount_removable=1
            autorun=1

            [ui]
            side_pane_mode=places
            show_hidden=1
          '';

          ".config/libfm/libfm.conf".text = ''
            [config]
            single_click=0
            use_trash=1
            confirm_del=1
            thumbnail_local=1
            thumbnail_max=2048

            [ui]
            big_icon_size=48
            small_icon_size=16
            thumbnail_size=128
            pane_icon_size=16
            show_thumbnail=1

            [places]
            places_home=0
            places_desktop=0
            places_root=0
            places_computer=0
            places_trash=1
            places_applications=1
            places_network=0
            places_unmounted=1
          '';
        };
      };
    };
}
