{
  cat = "bat";
  diff = "batdiff";

  #------------navigation------------
  l = "eza -l --group-directories-first";
  la = "eza -la --group-directories-first";
  lt = "eza -lah --tree";
  tree = "eza --tree --icons --tree";

  #------------utilities------------
  btar = "tar -cvf";
  untar = "tar -xf";
  rar = "unrar a";
  unrar = "unrar x";
  np = "nix-prefetch-github";
  wget = "wget2";

  #------------misc------------
  mkdir = "mkdir -pv";
  pvt = "incognito"; # temp disable zsh history
  pt = "eza --tree --group-directories-first --ignore-glob '*.lock' > tree.md"; # create markdown from tree

  #------------git------------
  gita = "git add";
  gitc = "git commit -m";
  gitd = "git diff";
  gitp = "git push";
  gits = "git status";
  gitl = "git log";

  #------------editor------------
  v = "nvim";
  suv = "sudoedit";

  #------------confirmations------------
  mv = "mv -i";
  cp = "cp -i";
  rm = "rm -i";

  #------------directory navigation------------
  dots = "cd $FLAKE";
  dl = "cd $XDG_DOWNLOAD_DIR";
  docs = "cd $XDG_DOCUMENTS_DIR";
  od = "cd $XDG_SHARED_DIR";
  gm = "cd $XDG_GAMES_DIR";
  pics = "cd $XDG_PICTURES_DIR";
  pj = "cd $XDG_PROJECTS_DIR";
  sc = "cd $XDG_SCREENSHOTS_DIR";
  st = "cd $XDG_STUFF_DIR";
}
