{
  flake.nixosModules.hyprlandScratchpads =
    { host, ... }:
    let
      inherit (host)
        calculator
        terminal
        tuiFileManager
        monitor
        ;
      scratchWidth = toString ((monitor.width * 6) / 10);
      scratchHeight = toString ((monitor.height * 3) / 4);
    in
    {
      hjem.users.${host.userName}.files.".config/hypr/hyprland.lua".text = ''
        local function toggleScratchpad(class, cmd, special)
          local found = false
          for _, w in pairs(hl.get_windows()) do
            if w.class == class then
              found = true
              break
            end
          end
          if found then
            hl.dispatch(hl.dsp.workspace.toggle_special(special))
          else
            local sub
            sub = hl.on("window.open", function(w)
              hl.dispatch(hl.dsp.workspace.toggle_special(special))
              sub:remove()
            end)
            hl.exec_cmd(cmd)
          end
        end

        hl.window_rule({ match = { class = "^(foot-term)$" }, workspace = "special:footterm", float = true, size = "${scratchWidth} ${scratchHeight}" })
        hl.bind("SUPER+BACKSLASH", function() toggleScratchpad("foot-term", "${terminal} -a foot-term", "footterm") end, { description = "toggle scratchpad terminal" })

        hl.window_rule({ match = { class = "^(foot-felix)$" }, workspace = "special:footfelix", float = true, size = "${scratchWidth} ${scratchHeight}" })
        hl.bind("SUPER+SHIFT+N", function() toggleScratchpad("foot-felix", "${terminal} -a foot-felix -e ${tuiFileManager}", "footfelix") end, { description = "toggle scratchpad file manager" })

        hl.window_rule({ match = { class = "^(foot-calc)$" }, workspace = "special:footcalc", float = true, size = "450 600" })
        hl.bind("SUPER+C", function() toggleScratchpad("foot-calc", "${terminal} -a foot-calc -e ${calculator}", "footcalc") end, { description = "toggle scratchpad calculator" })
      '';
    };
}
