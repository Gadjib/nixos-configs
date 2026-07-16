{ pkgs, lib, ... }:

let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = "macchiato";
    accents = [ "blue" ];
    size = "standard";
  };
  catppuccinKde = pkgs.catppuccin-kde.override {
    flavour = [ "macchiato" ];
    accents = [ "blue" ];
  };
  catppuccinKvantum = pkgs.catppuccin-kvantum.override {
    variant = "macchiato";
    accent = "blue";
  };
  defaultApplications = {
    "application/epub+zip" = [ "okularApplication_epub.desktop" ];
    "application/json" = [ "code.desktop" ];
    "application/msword" = [ "org.kde.okular.desktop" ];
    "application/ogg" = [ "vlc.desktop" ];
    "application/pdf" = [ "okularApplication_pdf.desktop" ];
    "application/rtf" = [ "org.kde.okular.desktop" ];
    "application/vnd.ms-excel" = [ "org.kde.okular.desktop" ];
    "application/vnd.ms-powerpoint" = [ "org.kde.okular.desktop" ];
    "application/vnd.oasis.opendocument.presentation" = [ "org.kde.okular.desktop" ];
    "application/vnd.oasis.opendocument.spreadsheet" = [ "org.kde.okular.desktop" ];
    "application/vnd.oasis.opendocument.text" = [ "org.kde.okular.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "org.kde.okular.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "org.kde.okular.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "org.kde.okular.desktop" ];
    "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
    "application/x-bzip2" = [ "org.kde.ark.desktop" ];
    "application/x-compressed-tar" = [ "org.kde.ark.desktop" ];
    "application/x-gzip" = [ "org.kde.ark.desktop" ];
    "application/x-shellscript" = [ "code.desktop" ];
    "application/x-tar" = [ "org.kde.ark.desktop" ];
    "application/xhtml+xml" = [ "firefox.desktop" ];
    "application/xml" = [ "code.desktop" ];
    "application/zip" = [ "org.kde.ark.desktop" ];
    "audio/aac" = [ "vlc.desktop" ];
    "audio/flac" = [ "vlc.desktop" ];
    "audio/mpeg" = [ "vlc.desktop" ];
    "audio/ogg" = [ "vlc.desktop" ];
    "audio/wav" = [ "vlc.desktop" ];
    "audio/x-flac" = [ "vlc.desktop" ];
    "audio/x-matroska" = [ "vlc.desktop" ];
    "audio/x-wav" = [ "vlc.desktop" ];
    "image/avif" = [ "org.kde.gwenview.desktop" ];
    "image/bmp" = [ "org.kde.gwenview.desktop" ];
    "image/gif" = [ "org.kde.gwenview.desktop" ];
    "image/heif" = [ "org.kde.gwenview.desktop" ];
    "image/jpeg" = [ "org.kde.gwenview.desktop" ];
    "image/jxl" = [ "org.kde.gwenview.desktop" ];
    "image/png" = [ "org.kde.gwenview.desktop" ];
    "image/svg+xml" = [ "org.kde.gwenview.desktop" ];
    "image/tiff" = [ "org.kde.gwenview.desktop" ];
    "image/webp" = [ "org.kde.gwenview.desktop" ];
    "inode/directory" = [ "org.kde.dolphin.desktop" ];
    "text/css" = [ "code.desktop" ];
    "text/csv" = [ "code.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "text/markdown" = [ "code.desktop" ];
    "text/plain" = [ "org.kde.kate.desktop" ];
    "text/x-c" = [ "code.desktop" ];
    "text/x-c++src" = [ "code.desktop" ];
    "text/x-go" = [ "code.desktop" ];
    "text/x-java" = [ "code.desktop" ];
    "text/x-javascript" = [ "code.desktop" ];
    "text/x-python" = [ "code.desktop" ];
    "text/x-rust" = [ "code.desktop" ];
    "text/x-typescript" = [ "code.desktop" ];
    "video/mp2t" = [ "vlc.desktop" ];
    "video/mp4" = [ "vlc.desktop" ];
    "video/mpeg" = [ "vlc.desktop" ];
    "video/ogg" = [ "vlc.desktop" ];
    "video/quicktime" = [ "vlc.desktop" ];
    "video/webm" = [ "vlc.desktop" ];
    "video/x-flv" = [ "vlc.desktop" ];
    "video/x-matroska" = [ "vlc.desktop" ];
    "video/x-msvideo" = [ "vlc.desktop" ];
    "x-scheme-handler/chrome" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
    "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
  };
in

{
  imports = [
    ./fish/fish.nix
    ./firefox/firefox.nix
    ./hypr/hyprland.nix
    ./kitty/kitty.nix
    ./mako/mako.nix
    ./nvim/nvim.nix
    ./packages/manual.nix
    ./rofi/rofi.nix
    ./scripts/network-menus.nix
    ./scripts/package-installer.nix
    ./starship/starship.nix
    ./telegram/telegram.nix
    ./waybar/waybar.nix
    ./wlogout/wlogout.nix
  ];

  home.username = "ilya";
  home.homeDirectory = "/home/ilya";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    waybar
    rofi
    awww
    mako
    wlogout
    hyprlock
    hypridle
    hyprpicker
    swayosd
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    xdg-utils
    bitwarden-desktop
    telegram-desktop
    networkmanagerapplet
    catppuccinGtk
    catppuccinKde
    catppuccinKvantum
    kdePackages.plasma-integration
    kdePackages.qqc2-desktop-style
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    hyprpolkitagent

    starship
    zoxide
    fzf
    bat
    eza
    fd
    ripgrep
    btop
    dust
    duf
    procs
    yazi
    trash-cli
    p7zip
    unzip
    rsync
    jq
    yq
    httpie
    tealdeer
    lazygit
    delta
    gh
    direnv
    nix-direnv
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    BROWSER = "firefox";
    KDE_SESSION_VERSION = "6";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "30";
    GTK_THEME = "catppuccin-macchiato-blue-standard";
    ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
    QT_QPA_PLATFORMTHEME = "kde";
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    SSH_AUTH_SOCK = "/home/ilya/.bitwarden-ssh-agent.sock";
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 30;
    };
    font = {
      name = "Inter";
      size = 10;
    };
    theme = {
      name = "catppuccin-macchiato-blue-standard";
      package = catppuccinGtk;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  xdg.enable = true;
  xdg.dataFile."color-schemes/CatppuccinMacchiatoBlue.colors".source =
    "${catppuccinKde}/share/color-schemes/CatppuccinMacchiatoBlue.colors";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = defaultApplications;
    associations.added = defaultApplications;
  };

  home.activation.clearRofiDrunCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f \
      "$HOME/.cache/rofi-drun-desktop.cache" \
      "$HOME/.cache/rofi3.druncache"
  '';

  home.activation.removeStaleIncyDesktopEntry = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "$HOME/.local/share/applications/incy.desktop"
  '';

  xdg.configFile = {
    "gtk-4.0/gtk.css".source =
      "${catppuccinGtk}/share/themes/catppuccin-macchiato-blue-standard/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${catppuccinGtk}/share/themes/catppuccin-macchiato-blue-standard/gtk-4.0/gtk-dark.css";
    "gtk-4.0/assets".source =
      "${catppuccinGtk}/share/themes/catppuccin-macchiato-blue-standard/gtk-4.0/assets";

    "qt5ct/qt5ct.conf".text = ''
      [Appearance]
      color_scheme_path=/home/ilya/.config/qt5ct/colors/catppuccin-macchiato.conf
      custom_palette=true
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=kvantum

      [Fonts]
      fixed="JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0"
      general="Inter,10,-1,5,50,0,0,0,0,0"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_underlined=true
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3
    '';

    "qt5ct/colors/catppuccin-macchiato.conf".text = ''
      [ColorScheme]
      active_colors=#ffcad3f5, #ff24273a, #ff494d64, #ff5b6078, #ff181926, #ff363a4f, #ffcad3f5, #ffffffff, #ffcad3f5, #ff1e2030, #ff181926, #ff24273a, #ff8aadf4, #ff181926, #ff8aadf4, #ffed8796, #ff363a4f, #ffcad3f5, #ff24273a, #ffcad3f5, #80ffffff
      disabled_colors=#ff6e738d, #ff24273a, #ff494d64, #ff5b6078, #ff181926, #ff363a4f, #ff6e738d, #ffffffff, #ff6e738d, #ff1e2030, #ff181926, #ff24273a, #ff8aadf4, #ff6e738d, #ff8aadf4, #ffed8796, #ff363a4f, #ff6e738d, #ff24273a, #ffcad3f5, #80ffffff
      inactive_colors=#ffcad3f5, #ff24273a, #ff494d64, #ff5b6078, #ff181926, #ff363a4f, #ffcad3f5, #ffffffff, #ffcad3f5, #ff1e2030, #ff181926, #ff24273a, #ff8aadf4, #ff181926, #ff8aadf4, #ffed8796, #ff363a4f, #ffcad3f5, #ff24273a, #ffcad3f5, #80ffffff
    '';

    "qt6ct/qt6ct.conf".text = ''
      [Appearance]
      color_scheme_path=/home/ilya/.config/qt6ct/colors/catppuccin-macchiato.conf
      custom_palette=true
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=kvantum

      [Fonts]
      fixed="JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0"
      general="Inter,10,-1,5,50,0,0,0,0,0"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_underlined=true
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3
    '';

    "qt6ct/colors/catppuccin-macchiato.conf".text = ''
      [ColorScheme]
      active_colors=#ffcad3f5, #ff24273a, #ff494d64, #ff5b6078, #ff181926, #ff363a4f, #ffcad3f5, #ffffffff, #ffcad3f5, #ff1e2030, #ff181926, #ff24273a, #ff8aadf4, #ff181926, #ff8aadf4, #ffed8796, #ff363a4f, #ffcad3f5, #ff24273a, #ffcad3f5, #80ffffff
      disabled_colors=#ff6e738d, #ff24273a, #ff494d64, #ff5b6078, #ff181926, #ff363a4f, #ff6e738d, #ffffffff, #ff6e738d, #ff1e2030, #ff181926, #ff24273a, #ff8aadf4, #ff6e738d, #ff8aadf4, #ffed8796, #ff363a4f, #ff6e738d, #ff24273a, #ffcad3f5, #80ffffff
      inactive_colors=#ffcad3f5, #ff24273a, #ff494d64, #ff5b6078, #ff181926, #ff363a4f, #ffcad3f5, #ffffffff, #ffcad3f5, #ff1e2030, #ff181926, #ff24273a, #ff8aadf4, #ff181926, #ff8aadf4, #ffed8796, #ff363a4f, #ffcad3f5, #ff24273a, #ffcad3f5, #80ffffff
    '';

    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=catppuccin-macchiato-blue
    '';
    "Kvantum/catppuccin-macchiato-blue".source =
      "${catppuccinKvantum}/share/Kvantum/catppuccin-macchiato-blue";

    "kdeglobals".text = ''
      [ColorEffects:Disabled]
      Color=36, 39, 58
      ColorAmount=0.30000000000000004
      ColorEffect=2
      ContrastAmount=0.1
      ContrastEffect=0
      IntensityAmount=-1
      IntensityEffect=0

      [ColorEffects:Inactive]
      ChangeSelectionColor=true
      Color=36, 39, 58
      ColorAmount=0.5
      ColorEffect=3
      ContrastAmount=0
      ContrastEffect=0
      Enable=true
      IntensityAmount=0
      IntensityEffect=0

      [Colors:Button]
      BackgroundAlternate=138,173,244
      BackgroundNormal=54,58,79
      DecorationFocus=138,173,244
      DecorationHover=54,58,79
      ForegroundActive=245,169,127
      ForegroundInactive=165,173,203
      ForegroundLink=138,173,244
      ForegroundNegative=237,135,150
      ForegroundNeutral=238,212,159
      ForegroundNormal=202,211,245
      ForegroundPositive=166,218,149
      ForegroundVisited=198,160,246

      [Colors:Complementary]
      BackgroundAlternate=24,25,38
      BackgroundNormal=30,32,48
      DecorationFocus=138,173,244
      DecorationHover=54,58,79
      ForegroundActive=245,169,127
      ForegroundInactive=165,173,203
      ForegroundLink=138,173,244
      ForegroundNegative=237,135,150
      ForegroundNeutral=238,212,159
      ForegroundNormal=202,211,245
      ForegroundPositive=166,218,149
      ForegroundVisited=198,160,246

      [Colors:Header]
      BackgroundAlternate=24,25,38
      BackgroundNormal=30,32,48
      DecorationFocus=138,173,244
      DecorationHover=54,58,79
      ForegroundActive=245,169,127
      ForegroundInactive=165,173,203
      ForegroundLink=138,173,244
      ForegroundNegative=237,135,150
      ForegroundNeutral=238,212,159
      ForegroundNormal=202,211,245
      ForegroundPositive=166,218,149
      ForegroundVisited=198,160,246

      [Colors:Selection]
      BackgroundAlternate=138,173,244
      BackgroundNormal=138,173,244
      DecorationFocus=138,173,244
      DecorationHover=54,58,79
      ForegroundActive=245,169,127
      ForegroundInactive=30,32,48
      ForegroundLink=138,173,244
      ForegroundNegative=237,135,150
      ForegroundNeutral=238,212,159
      ForegroundNormal=24,25,38
      ForegroundPositive=166,218,149
      ForegroundVisited=198,160,246

      [Colors:Tooltip]
      BackgroundAlternate=27,25,35
      BackgroundNormal=36,39,58
      DecorationFocus=138,173,244
      DecorationHover=54,58,79
      ForegroundActive=245,169,127
      ForegroundInactive=165,173,203
      ForegroundLink=138,173,244
      ForegroundNegative=237,135,150
      ForegroundNeutral=238,212,159
      ForegroundNormal=202,211,245
      ForegroundPositive=166,218,149
      ForegroundVisited=198,160,246

      [Colors:View]
      BackgroundAlternate=30,32,48
      BackgroundNormal=36,39,58
      DecorationFocus=138,173,244
      DecorationHover=54,58,79
      ForegroundActive=245,169,127
      ForegroundInactive=165,173,203
      ForegroundLink=138,173,244
      ForegroundNegative=237,135,150
      ForegroundNeutral=238,212,159
      ForegroundNormal=202,211,245
      ForegroundPositive=166,218,149
      ForegroundVisited=198,160,246

      [Colors:Window]
      BackgroundAlternate=24,25,38
      BackgroundNormal=30,32,48
      DecorationFocus=138,173,244
      DecorationHover=54,58,79
      ForegroundActive=245,169,127
      ForegroundInactive=165,173,203
      ForegroundLink=138,173,244
      ForegroundNegative=237,135,150
      ForegroundNeutral=238,212,159
      ForegroundNormal=202,211,245
      ForegroundPositive=166,218,149
      ForegroundVisited=198,160,246

      [General]
      ColorScheme=CatppuccinMacchiatoBlue
      Name=Catppuccin Macchiato Blue
      accentActiveTitlebar=false
      fixed=JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0
      font=Inter,10,-1,5,50,0,0,0,0,0
      shadeSortColumn=true

      [Icons]
      Theme=Papirus-Dark

      [KDE]
      contrast=4
      LookAndFeelPackage=org.kde.breezedark.desktop

      [WM]
      activeBackground=36,39,58
      activeBlend=202,211,245
      activeForeground=202,211,245
      inactiveBackground=24,25,38
      inactiveBlend=165,173,203
      inactiveForeground=165,173,203
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Bibata-Modern-Ice";
      font-name = "Inter 10";
      gtk-theme = "catppuccin-macchiato-blue-standard";
      icon-theme = "Papirus-Dark";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
    };
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
