{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      cursor_shape = "beam";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      copy_on_select = "clipboard";
      confirm_os_window_close = 0;
      background_opacity = "0.82";

      foreground = "#cad3f5";
      background = "#24273a";
      selection_foreground = "#24273a";
      selection_background = "#f4dbd6";
      cursor = "#f4dbd6";
      color0 = "#494d64";
      color1 = "#ed8796";
      color2 = "#a6da95";
      color3 = "#eed49f";
      color4 = "#8aadf4";
      color5 = "#f5bde6";
      color6 = "#8bd5ca";
      color7 = "#b8c0e0";
      color8 = "#5b6078";
      color9 = "#ed8796";
      color10 = "#a6da95";
      color11 = "#eed49f";
      color12 = "#8aadf4";
      color13 = "#f5bde6";
      color14 = "#8bd5ca";
      color15 = "#a5adcb";
    };
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
  };
}
