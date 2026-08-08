{ self, ... }:
{
  flake.nixosModules.nvidia =
    { ... }:
    {
      imports = with self.nixosModules; [
        nvidiaFancontrol
        nvidiaOpengl
        nvidiaSettings
        nvidiaVaapi
      ];
    };
}
