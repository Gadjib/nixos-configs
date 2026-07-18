{ pkgs, ... }:

let
  appearance = import ../appearance.nix { inherit pkgs; };
in

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = appearance.icons.name;
      disable-history = false;
      max-history-size = 100;
      sort = true;
      sorting-method = "fzf";
      matching = "fuzzy";
      drun-use-desktop-cache = false;
      drun-display-format = "{name}";
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
    };
    theme = ./theme.rasi;
  };

  xdg.configFile."rofi/theme.rasi".source = ./theme.rasi;
}
