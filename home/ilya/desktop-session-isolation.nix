{ pkgs, ... }:

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

  desktopSessionProfile = pkgs.writeShellApplication {
    name = "desktop-session-profile";
    runtimeInputs = with pkgs; [
      coreutils
      dconf
      systemd
      util-linux
    ];
    text = ''
      set -euo pipefail

      state_root="$HOME/.local/state/nixos-desktop-isolation"
      session_state="$state_root/active-hyprland"
      initialized="$state_root/plasma-reset-v1"
      lock_file="''${XDG_RUNTIME_DIR:?}/nixos-desktop-isolation.lock"

      hypr_root="$HOME/.config/.desktop-profiles/hyprland"
      managed_ids=(
        kdeglobals
        kded5rc
        gtk3-settings
        gtk4-settings
        gtk4-css
        gtk4-dark-css
        gtk4-assets
        firefox-userchrome
      )
      managed_paths=(
        .config/kdeglobals
        .config/kded5rc
        .config/gtk-3.0/settings.ini
        .config/gtk-4.0/settings.ini
        .config/gtk-4.0/gtk.css
        .config/gtk-4.0/gtk-dark.css
        .config/gtk-4.0/assets
        .mozilla/firefox/hyprland/chrome/userChrome.css
      )
      managed_sources=(
        "$HOME/.config/.home-manager-kdeglobals"
        "$HOME/.config/.home-manager-kded5rc"
        "$hypr_root/gtk-3.0/settings.ini"
        "$hypr_root/gtk-4.0/settings.ini"
        "$hypr_root/gtk-4.0/gtk.css"
        "$hypr_root/gtk-4.0/gtk-dark.css"
        "$hypr_root/gtk-4.0/assets"
        "$hypr_root/firefox/userChrome.css"
      )

      plasma_reset_paths=(
        .config/bluedevilglobalrc
        .config/breezerc
        .config/gtk-3.0/settings.ini
        .config/gtk-4.0/assets
        .config/gtk-4.0/gtk-dark.css
        .config/gtk-4.0/gtk.css
        .config/gtk-4.0/settings.ini
        .config/gtkrc
        .config/gtkrc-2.0
        .config/kcminputrc
        .config/kded5rc
        .config/kded6rc
        .config/kdeglobals
        .config/kglobalshortcutsrc
        .config/krunnerrc
        .config/kscreenlockerrc
        .config/ksmserverrc
        .config/kwinrc
        .config/kxkbrc
        .config/mimeapps.list
        .config/plasma-localerc
        .config/plasma-org.kde.plasma.desktop-appletsrc
        .config/plasmaparc
        .config/plasmashellrc
        .config/powermanagementprofilesrc
        .config/xsettingsd/xsettingsd.conf
        .local/share/applications/mimeapps.list
        .local/share/kscreen
      )

      initialize_plasma_defaults() {
        local backup relative source target timestamp

        [[ ! -e "$initialized" ]] || return 0

        timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
        backup="$state_root/backups/plasma-before-isolation-$timestamp"
        mkdir -p "$backup"

        for relative in "''${plasma_reset_paths[@]}"; do
          source="$HOME/$relative"
          if [[ -e "$source" || -L "$source" ]]; then
            target="$backup/$relative"
            mkdir -p "$(dirname "$target")"
            mv -- "$source" "$target"
          fi
        done

        dconf dump /org/gnome/desktop/interface/ > "$backup/dconf-interface.ini" || true
        dconf reset -f /org/gnome/desktop/interface/ || true

        mkdir -p "$state_root"
        printf '%s\n' "$backup" > "$initialized"
      }

      copy_hypr_source() {
        local source="$1"
        local target="$2"

        [[ -e "$source" || -L "$source" ]] || {
          printf 'desktop-session-profile: missing Hyprland source: %s\n' "$source" >&2
          return 1
        }

        mkdir -p "$(dirname "$target")"
        if [[ -d "$source" ]]; then
          cp -aL -- "$source" "$target"
          chmod -R u+rwX -- "$target"
        else
          install -m 0600 -- "$source" "$target"
        fi
      }

      remove_writable_tree() {
        local target="$1"

        if [[ -e "$target" || -L "$target" ]]; then
          chmod -R u+w -- "$target" 2>/dev/null || true
          rm -rf -- "$target"
        fi
      }

      apply_hyprland_defaults() {
        local index target

        for index in "''${!managed_ids[@]}"; do
          target="$HOME/''${managed_paths[$index]}"
          remove_writable_tree "$target"
          copy_hypr_source "''${managed_sources[$index]}" "$target"
        done

        dconf reset -f /org/gnome/desktop/interface/
        dconf load /org/gnome/desktop/interface/ < "$hypr_root/dconf-interface.ini"
      }

      activate_hyprland() {
        local index id relative target

        initialize_plasma_defaults
        # Remove the pre-fix cache whose store-derived GTK assets may be
        # read-only. It is no longer part of the session state machine.
        remove_writable_tree "$state_root/hyprland"
        if [[ ! -e "$session_state/.active" ]]; then
          remove_writable_tree "$session_state"
          mkdir -p "$session_state/files"

          for index in "''${!managed_ids[@]}"; do
            id="''${managed_ids[$index]}"
            relative="''${managed_paths[$index]}"
            target="$HOME/$relative"

            if [[ "$id" == firefox-userchrome ]]; then
              # Plasma deliberately has no userChrome.css. Never capture the
              # currently active Hyprland CSS as Plasma state during migration.
              remove_writable_tree "$target"
              touch "$session_state/files/$id.absent"
            elif [[ -e "$target" || -L "$target" ]]; then
              mv -- "$target" "$session_state/files/$id"
            else
              touch "$session_state/files/$id.absent"
            fi
          done

          dconf dump /org/gnome/desktop/interface/ > "$session_state/dconf-interface.ini"
          touch "$session_state/.active"
        fi

        # Always reapply the profile. This also repairs a stale .active marker
        # left by a crash, reboot or an interrupted previous logout.
        apply_hyprland_defaults
      }

      deactivate_hyprland() {
        local index id relative target saved

        initialize_plasma_defaults
        if [[ -e "$session_state/.active" ]]; then
          for index in "''${!managed_ids[@]}"; do
            id="''${managed_ids[$index]}"
            relative="''${managed_paths[$index]}"
            target="$HOME/$relative"
            saved="$session_state/files/$id"

            remove_writable_tree "$target"
            if [[ -e "$saved" || -L "$saved" ]]; then
              mkdir -p "$(dirname "$target")"
              mv -- "$saved" "$target"
            fi
          done

          dconf reset -f /org/gnome/desktop/interface/
          if [[ -s "$session_state/dconf-interface.ini" ]]; then
            dconf load /org/gnome/desktop/interface/ < "$session_state/dconf-interface.ini"
          fi

          rm -rf -- "$session_state"
        fi

        systemctl --user unset-environment \
          ADW_DEBUG_COLOR_SCHEME \
          BROWSER \
          GTK_THEME \
          HYPRCURSOR_SIZE \
          HYPRCURSOR_THEME \
          KDE_SESSION_VERSION \
          QT_QPA_PLATFORMTHEME \
          QT_QUICK_CONTROLS_STYLE \
          XCURSOR_SIZE \
          XCURSOR_THEME \
          XDG_CURRENT_DESKTOP \
          XDG_SESSION_DESKTOP \
          XDG_MENU_PREFIX || true
      }

      mkdir -p "$(dirname "$lock_file")"
      exec 9> "$lock_file"
      flock 9

      case "''${1:-}" in
        hyprland)
          activate_hyprland
          ;;
        plasma)
          deactivate_hyprland
          ;;
        *)
          printf 'Usage: desktop-session-profile {hyprland|plasma}\n' >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [ desktopSessionProfile ];

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
