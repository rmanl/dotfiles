{ inputs }:
{
  system = "x86_64-linux";
  userName = "rma";
  handle = "rmanl";
  sshKeyName = "id_rma";
  hostWM = "mango";
  colorTheme = "nord";
  wallpaper = "station";
  browser = "librewolf";
  isDesktop = false;
  isDualBoot = false;
  isGaming = false;
  isLaptop = false;
  isMinimal = false;
  isMultiDisk = false;
  hashedPassword = "$y$j9T$Ac.m5IZ6ku/nrqK9K9kBi1$lRHp3Xg4Vk7Ly/VAiv5d839VlwDRNt2w9ACMMKe8kR2";
}
// (
  if inputs == null then
    { }
  else
    {
      inherit (inputs.nix-secrets)
        domain
        email
        location
        networking
        userFullName
        ;
    }
)
