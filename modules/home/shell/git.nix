{
  flake.nixosModules.git =
    {
      host,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (host)
        userName
        handle
        sshKeyName
        email
        ;
      home = "/home/${userName}";
      publicGitEmail = email.gitHub;
      publicKey = "${home}/.ssh/${sshKeyName}.pub";
      privateGitConfig = "${home}/.config/git/gitconfig.private";
    in
    {
      hjem.users.${userName} = {
        packages = with pkgs; [
          git
          delta
        ];
        files = {
          ".config/git/config".text = with config.colors.withHashtag; ''
            [user]
              name = ${handle}
              email = ${publicGitEmail}
              signingKey = ${publicKey}

            [log]
              showSignature = true

            [core]
              pager = delta

            [interactive]
              diffFilter = delta --color-only

            [delta]
              navigate = true
              line-numbers = true
              syntax-theme = "none"
              file-style = "${base0D} bold"
              hunk-header-style = "${base0E}"
              minus-style = "${base05} ${diffRed}"
              plus-style = "${base05} ${diffGreen}"

            [init]
              defaultBranch = main

            [pull]
              rebase = true

            [url "ssh://git@github.com"]
              insteadOf = https://github.com

            [url "ssh://git@codeberg.org"]
              insteadOf = https://codeberg.org

            [url "ssh://git@gitlab.com"]
              insteadOf = https://gitlab.com

            [includeIf "gitdir:${home}/dev/"]
              path = ${privateGitConfig}

            [includeIf "gitdir:${home}/src/"]
              path = ${privateGitConfig}

            [includeIf "gitdir:${home}/source/"]
              path = ${privateGitConfig}

            [commit]
              gpgsign = true

            [gpg]
              format = ssh

            [gpg "ssh"]
              allowedSignersFile = ${home}/.ssh/allowed_signers
          '';

          ".ssh/allowed_signers".text = ''
            ${publicGitEmail} ${lib.fileContents ../../users/primary/keys/${sshKeyName}.pub}
          '';

          ".config/git/gitconfig.private".text = ''
            [user]
              name = ${handle}
              email = ${publicGitEmail}
          '';
        };
      };
    };
}
