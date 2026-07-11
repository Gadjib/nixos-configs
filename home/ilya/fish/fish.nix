{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
      zoxide init fish | source
      direnv hook fish | source

      if command -q fzf
        fzf --fish | source
      end

      set -gx SSH_AUTH_SOCK /home/ilya/.bitwarden-ssh-agent.sock
    '';
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -lah --icons --group-directories-first";
      la = "eza -la --icons --group-directories-first";
      cat = "bat";
      grep = "rg";
      lg = "lazygit";
      rebuild-test = "nh os test /home/ilya/nixos-config";
      rebuild-switch = "nh os switch /home/ilya/nixos-config";
    };
    functions.install = ''
      if test (count $argv) -ge 1; and not string match -q -- "-*" $argv[1]
        /home/ilya/.local/bin/nix-install-package $argv
      else
        command install $argv
      end
    '';
  };
}
