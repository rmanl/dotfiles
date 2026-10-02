{
  flake.nixosModules.mangoEnv =
    { host, ... }:
    {
      hjem.users.${host.userName} = {
        # prevent error message env.conf missing
        files.".config/mango/env.conf".text = "";
      };
    };
}
