{
  home.file.".local/bin/telegram-hyprland" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [[ "''${XDG_CURRENT_DESKTOP:-}" == *Hyprland* || "''${XDG_SESSION_DESKTOP:-}" == *Hyprland* ]]; then
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      fi

      exec Telegram "$@"
    '';
  };

  xdg.desktopEntries."org.telegram.desktop" = {
    name = "Telegram";
    comment = "New era of messaging";
    exec = "/home/ilya/.local/bin/telegram-hyprland -- %U";
    icon = "org.telegram.desktop";
    terminal = false;
    startupNotify = true;
    categories = [ "Chat" "Network" "InstantMessaging" "Qt" ];
    mimeType = [
      "x-scheme-handler/tg"
      "x-scheme-handler/tonsite"
    ];
    settings = {
      Keywords = "tg;chat;im;messaging;messenger;sms;tdesktop;";
      StartupWMClass = "TelegramDesktop";
      SingleMainWindow = "true";
      X-GNOME-UsesNotifications = "true";
      X-GNOME-SingleWindow = "true";
    };
  };
}
