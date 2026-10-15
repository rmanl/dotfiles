{
  flake.nixosModules.mangoScratchpads =
    { host, config, ... }:
    let
      inherit (host)
        calculator
        terminal
        tuiFileManager
        monitor
        ;
      mod = "SUPER";
      scratchWidth = toString ((monitor.width * 6) / 10);
      scratchHeight = toString ((monitor.height * 3) / 4);
    in
    {
      hjem.users.${host.userName}.files.".config/mango/scratchpads.conf".text = ''
        scratchpadcolor=0x${config.colors.base0F}ff

        # scratchpad
        bind=${mod},backslash,toggle_named_scratchpad,foot-term,none,${terminal} -a foot-term # toggle terminal
        windowrule=isfloating:1,isnamedscratchpad:1,width:${scratchWidth},height:${scratchHeight},appid:foot-term

        bind=${mod}+SHIFT,n,toggle_named_scratchpad,foot-felix,none,${terminal} -a foot-felix -e ${tuiFileManager} # toggle file manager
        windowrule=isfloating:1,isnamedscratchpad:1,width:${scratchWidth},height:${scratchHeight},appid:foot-felix

        bind=${mod},c,toggle_named_scratchpad,foot-calc,none,${terminal} -a foot-calc -e ${calculator} # toggle calculator
        windowrule=isfloating:1,isnamedscratchpad:1,width:450,height:600,appid:foot-calc
      '';
    };
}
