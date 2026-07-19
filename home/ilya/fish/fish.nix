{ pkgs, ... }:

let
  agnosterTheme = pkgs.fetchFromGitHub {
    owner = "oh-my-fish";
    repo = "theme-agnoster";
    rev = "4c5518c89ebcef393ef154c9f576a52651400d27";
    hash = "sha256-OFESuesnfqhXM0aij+79kdxjp4xgCt28YwTrcwQhFMU=";
  };
in

{
  home.packages = [ pkgs.oh-my-fish ];

  xdg.configFile = {
    "omf/theme".text = "agnoster\n";
    "omf/themes/agnoster".source = agnosterTheme;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx OMF_PATH ${pkgs.oh-my-fish}/share/oh-my-fish
      set -gx OMF_CONFIG /home/ilya/.config/omf
      source $OMF_PATH/init.fish

      # Agnoster mistakes the regular NixOS PATH for an ephemeral `nix shell`.
      # Load the theme before overriding it so Fish autoload cannot restore the
      # upstream implementation on the first prompt render.
      source $OMF_CONFIG/themes/agnoster/functions/fish_prompt.fish
      functions --erase prompt_virtual_env
      function prompt_virtual_env
        set -l envs

        if test -n "$CONDA_DEFAULT_ENV"
          set -a envs "conda[$CONDA_DEFAULT_ENV]"
        end

        if test -n "$VIRTUAL_ENV"
          set -a envs "py["(basename "$VIRTUAL_ENV")"]"
        end

        if test -n "$IN_NIX_SHELL"
          set -a envs "nix[$IN_NIX_SHELL]"
        end

        if test (count $envs) -gt 0
          prompt_segment $color_virtual_env_bg $color_virtual_env_str (string join " " $envs)
        end
      end

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
    functions.nix-install = ''
      /home/ilya/.local/bin/nix-install-package $argv
    '';
  };
}
