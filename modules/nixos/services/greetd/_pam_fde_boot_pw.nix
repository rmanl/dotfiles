{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "pam_fde_boot_pw";
  version = "0.1";

  src = pkgs.fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = "pam_fde_boot_pw";
    rev = "49bf498fd8d13f73e4a24221818a8a5d2af20088";
    hash = "sha256-dS9ufryg3xfxgUzJKDgrvMZP2qaYH+WJQFw1ogl1isc=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    pam
    keyutils
  ];

  mesonFlags = [
    (pkgs.lib.mesonOption "pam-mod-dir" "${placeholder "out"}/lib/security")
  ];
}
