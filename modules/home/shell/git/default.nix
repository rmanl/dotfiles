{
  config,
  lib,
  ...
}:
let
  cfg = config.homeSpec.shell.git;
  inherit (config.hostSpec) handle home;
  publicGitEmail = config.hostSpec.email.gitHub;
  sshFolder = "${home}/.ssh";
  publicKey = "${sshFolder}/id_rma.pub";
  privateGitConfig = "${home}/.config/git/gitconfig.private";
in
{
  options.homeSpec.shell.git = {
    enable = lib.mkEnableOption "Enable git module";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      config = {
        user = {
          name = handle;
          email = publicGitEmail;
        };
        log.showSignature = "true";
        init.defaultBranch = "main";
        pull.rebase = "true";
        url = {
          "ssh://git@github.com" = {
            insteadOf = "https://github.com";
          };
          "ssh://git@codeberg.org" = {
            insteadOf = "https://codeberg.org";
          };
          "ssh://git@gitlab.com" = {
            insteadOf = "https://gitlab.com";
          };
        };

        includeIf = {
          "gitdir:${home}/dev/".path = privateGitConfig;
          "gitdir:${home}/src/".path = privateGitConfig;
          "gitdir:${home}/source/".path = privateGitConfig;
        };

        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signing.key = "${publicKey}";
        user = {
          signByDefault = true;
          signingkey = "${publicKey}";
        };
        gpg.ssh.allowedSignersFile = "${home}/.ssh/allowed_signers";
      };
    };

    hjem.users.${config.hostSpec.userName}.files = {
      ".ssh/allowed_signers".text = ''
        ${publicGitEmail} ${lib.fileContents (../../../users/primary/keys/id_rma.pub)}
      '';
      ".config/git/gitconfig.private".text = ''
        [user]
          name = "${handle}"
          email = ${publicGitEmail}
      '';
    };
  };
}
