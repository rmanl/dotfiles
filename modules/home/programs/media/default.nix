{ self, ... }:
{
  flake.nixosModules.media =
    { ... }:
    {
      imports = with self.nixosModules; [
        mediaCommon
        mediaSpotify
      ];
    };
}
