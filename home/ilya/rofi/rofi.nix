{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      disable-history = false;
      max-history-size = 100;
      sort = true;
      sorting-method = "fzf";
      matching = "fuzzy";
      drun-use-desktop-cache = true;
      drun-display-format = "{name}";
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
    };
    theme = ./theme.rasi;
  };

  xdg.configFile."rofi/theme.rasi".source = ./theme.rasi;
}
