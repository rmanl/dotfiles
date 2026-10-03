{
  flake.nixosModules.mangoScratchpads =
    { host, config, ... }:
    let
      inherit (host) calculator terminal tuiFileManager;
      mod = "SUPER";
    in
    {
      hjem.users.${host.userName}.files.".config/mango/scratchpads.conf".text = ''
        scratchpadcolor=0x${config.colors.base0F}ff

        # scratchpad
        bind=${mod},backslash,toggle_named_scratchpad,foot-term,none,${terminal} -a foot-term # toggle terminal
        windowrule=isfloating:1,isnamedscratchpad:1,width:1600,height:1100,appid:foot-term

        bind=${mod}+SHIFT,n,toggle_named_scratchpad,foot-felix,none,${terminal} -a foot-felix -e ${tuiFileManager} # toggle file manager
        windowrule=isfloating:1,isnamedscratchpad:1,width:1600,height:1100,appid:foot-felix

        bind=${mod},c,toggle_named_scratchpad,foot-calc,none,${terminal} -a foot-calc -e ${calculator} # toggle calculator
        windowrule=isfloating:1,isnamedscratchpad:1,width:450,height:600,appid:foot-calc
      '';
    };
}
