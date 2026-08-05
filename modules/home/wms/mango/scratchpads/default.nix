{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.wms.mango.scratchpads;
  mod = "SUPER";
in
{
  options.homeSpec.wms.mango.scratchpads = {
    enable = lib.mkEnableOption "Enable mango scratchpads module";
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.hostSpec.userName}.files.".config/mango/scratchpads.conf".text = ''
      scratchpadcolor=0x${config.colors.base0F}ff

      # empty terminal
      bind=${mod},backslash,toggle_named_scratchpad,foot-term,none,foot -a foot-term
      windowrule=isfloating:1,isnamedscratchpad:1,width:1600,height:1100,appid:foot-term

      # felix file manager
      bind=${mod}+SHIFT,n,toggle_named_scratchpad,foot-felix,none,foot -a foot-felix -e fx
      windowrule=isfloating:1,isnamedscratchpad:1,width:1600,height:1100,appid:foot-felix

      # calculator
      bind=${mod},c,toggle_named_scratchpad,foot-calc,none,foot -a foot-calc -e wcalc
      windowrule=isfloating:1,isnamedscratchpad:1,width:450,height:600,appid:foot-calc
    '';
  };
}
