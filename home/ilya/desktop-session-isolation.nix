{ lib, pkgs, ... }:

let
  appearance = import ./appearance.nix { inherit pkgs; };
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = appearance.gtk.variant;
    accents = [ appearance.gtk.accent ];
    size = appearance.gtk.size;
  };

  drkonqiDisplayAvailable = pkgs.writeShellApplication {
    name = "drkonqi-display-available";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -euo pipefail

      shopt -s nullglob
      for socket in "''${XDG_RUNTIME_DIR:?}"/wayland-*; do
        if [[ -S "$socket" ]]; then
          exit 0
        fi
      done

      # Keep the normal crash reporter available in an X11 Plasma session,
      # but reject a stale DISPLAY left behind after its server has exited.
      if [[ "''${DISPLAY:-}" =~ ^:([0-9]+)(\.[0-9]+)?$ ]]; then
        [[ -S "/tmp/.X11-unix/X''${BASH_REMATCH[1]}" ]]
        exit
      fi

      exit 1
    '';
  };

  configurePlasmaSleepPolicy = pkgs.writeShellApplication {
    name = "configure-plasma-sleep-policy";
    runtimeInputs = [ pkgs.kdePackages.kconfig ];
    text = ''
      set -euo pipefail

      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      for profile in AC Battery LowBattery; do
        group_args=(
          --file powerdevilrc
          --group "$profile"
          --group SuspendAndShutdown
        )

        kwriteconfig6 "''${group_args[@]}" --key AutoSuspendAction 0
        kwriteconfig6 "''${group_args[@]}" --key LidAction 1
        kwriteconfig6 "''${group_args[@]}" \
          --key InhibitLidActionWhenExternalMonitorPresent --type bool false
        kwriteconfig6 "''${group_args[@]}" --key SleepMode 3
      done
    '';
  };

  desktopSessionProfile = pkgs.writeShellApplication {
    name = "desktop-session-profile";
    runtimeInputs = with pkgs; [
      coreutils
      dconf
      systemd
      util-linux
    ];
    text = builtins.readFile ./desktop-session-profile.sh;
  };
in
{
  home.packages = [
    configurePlasmaSleepPolicy
    desktopSessionProfile
  ];

  home.activation.configurePlasmaSleepPolicy =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${configurePlasmaSleepPolicy}/bin/configure-plasma-sleep-policy
    '';

  xdg.configFile = {
    # Override the package-provided XDG autostart entries. Plasma sees these
    # higher-priority files and skips them; Hyprland uses the supervised user
    # services instead of starting duplicate applet processes.
    "autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Blueman Applet (Hyprland service)
      Exec=blueman-applet
      NotShowIn=KDE;
      X-systemd-skip=true
    '';

    "autostart/nm-applet.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=NetworkManager Applet (Hyprland service)
      Exec=nm-applet --indicator
      NotShowIn=KDE;
      X-systemd-skip=true
    '';

    ".desktop-profiles/hyprland/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
      gtk-cursor-theme-name=${appearance.cursor.name}
      gtk-cursor-theme-size=${toString appearance.cursor.size}
      gtk-font-name=${appearance.fonts.general.name} ${toString appearance.fonts.general.size}
      gtk-icon-theme-name=${appearance.icons.name}
      gtk-theme-name=${appearance.gtk.name}
    '';

    ".desktop-profiles/hyprland/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=true
      gtk-cursor-theme-name=${appearance.cursor.name}
      gtk-cursor-theme-size=${toString appearance.cursor.size}
      gtk-font-name=${appearance.fonts.general.name} ${toString appearance.fonts.general.size}
      gtk-icon-theme-name=${appearance.icons.name}
    '';

    ".desktop-profiles/hyprland/gtk-4.0/gtk.css".source =
      "${catppuccinGtk}/share/themes/${appearance.gtk.name}/gtk-4.0/gtk.css";
    ".desktop-profiles/hyprland/gtk-4.0/gtk-dark.css".source =
      "${catppuccinGtk}/share/themes/${appearance.gtk.name}/gtk-4.0/gtk-dark.css";
    ".desktop-profiles/hyprland/gtk-4.0/assets".source =
      "${catppuccinGtk}/share/themes/${appearance.gtk.name}/gtk-4.0/assets";

    ".desktop-profiles/hyprland/firefox/userChrome.css".text = ''
      @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

      .titlebar-buttonbox-container,
      .titlebar-buttonbox,
      .titlebar-button {
        display: none !important;
      }

      #TabsToolbar .titlebar-spacer {
        display: none !important;
      }
    '';

    ".desktop-profiles/hyprland/dconf-interface.ini".text = ''
      [/]
      color-scheme='prefer-dark'
      cursor-blink=true
      cursor-blink-time=1000
      cursor-size=${toString appearance.cursor.size}
      cursor-theme='${appearance.cursor.name}'
      document-font-name='${appearance.fonts.general.name}  ${toString appearance.fonts.general.size}'
      enable-animations=true
      font-name='${appearance.fonts.general.name} ${toString appearance.fonts.general.size}'
      gtk-theme='${appearance.gtk.name}'
      icon-theme='${appearance.icons.name}'
      monospace-font-name='${appearance.fonts.monospace.name} ${toString appearance.fonts.monospace.size}'
      scaling-factor=uint32 1
      text-scaling-factor=1.0
      toolbar-style='text'
    '';

    "plasma-workspace/env/00-desktop-session-profile.sh" = {
      executable = true;
      text = ''
        ${desktopSessionProfile}/bin/desktop-session-profile plasma
        ${configurePlasmaSleepPolicy}/bin/configure-plasma-sleep-policy

        unset ADW_DEBUG_COLOR_SCHEME
        unset BROWSER
        unset GTK_THEME
        unset HYPRCURSOR_SIZE
        unset HYPRCURSOR_THEME
        unset QT_STYLE_OVERRIDE
        unset QT_QUICK_CONTROLS_STYLE
        unset XDG_MENU_PREFIX
      '';
    };

    # Plasma installs this template for every graphical session. If a process
    # dumps core while a Wayland compositor is already shutting down, the
    # graphical launcher otherwise aborts for lack of a display and reports
    # its own abort recursively. Skip only that display-less invocation.
    "systemd/user/drkonqi-coredump-launcher@.service.d/10-live-display.conf".text = ''
      [Service]
      ExecCondition=${drkonqiDisplayAvailable}/bin/drkonqi-display-available
    '';
  };

  systemd.user.services.hyprland-desktop-session-profile = {
    Unit = {
      Description = "Activate isolated Hyprland desktop settings";
      Before = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${desktopSessionProfile}/bin/desktop-session-profile hyprland";
      ExecStop = "${desktopSessionProfile}/bin/desktop-session-profile plasma";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
