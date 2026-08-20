{ pkgs, ... }:

let
  appearance = import ./appearance.nix { inherit pkgs; };
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = appearance.gtk.variant;
    accents = [ appearance.gtk.accent ];
    size = appearance.gtk.size;
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
      hypr_state="$state_root/hyprland"
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
      )
      managed_paths=(
        .config/kdeglobals
        .config/kded5rc
        .config/gtk-3.0/settings.ini
        .config/gtk-4.0/settings.ini
        .config/gtk-4.0/gtk.css
        .config/gtk-4.0/gtk-dark.css
        .config/gtk-4.0/assets
      )
      managed_sources=(
        "$HOME/.config/.home-manager-kdeglobals"
        "$HOME/.config/.home-manager-kded5rc"
        "$hypr_root/gtk-3.0/settings.ini"
        "$hypr_root/gtk-4.0/settings.ini"
        "$hypr_root/gtk-4.0/gtk.css"
        "$hypr_root/gtk-4.0/gtk-dark.css"
        "$hypr_root/gtk-4.0/assets"
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
        else
          install -m 0600 -- "$source" "$target"
        fi
      }

      refresh_hyprland_defaults() {
        local fingerprint index source

        fingerprint="$({
          for source in "''${managed_sources[@]}" "$hypr_root/dconf-interface.ini"; do
            readlink -f -- "$source"
          done
        } | sha256sum | cut -d ' ' -f 1)"

        if [[ -r "$hypr_state/source-fingerprint" ]] \
          && [[ "$(< "$hypr_state/source-fingerprint")" == "$fingerprint" ]]; then
          return 0
        fi

        rm -rf -- "$hypr_state"
        mkdir -p "$hypr_state/files"
        for index in "''${!managed_ids[@]}"; do
          copy_hypr_source \
            "''${managed_sources[$index]}" \
            "$hypr_state/files/''${managed_ids[$index]}"
        done
        install -m 0600 -- \
          "$hypr_root/dconf-interface.ini" \
          "$hypr_state/dconf-interface.ini"
        printf '%s\n' "$fingerprint" > "$hypr_state/source-fingerprint"
      }

      activate_hyprland() {
        local index id relative source target

        initialize_plasma_defaults
        [[ ! -e "$session_state/.active" ]] || return 0
        refresh_hyprland_defaults

        rm -rf -- "$session_state"
        mkdir -p "$session_state/files"

        for index in "''${!managed_ids[@]}"; do
          id="''${managed_ids[$index]}"
          relative="''${managed_paths[$index]}"
          source="$hypr_state/files/$id"
          target="$HOME/$relative"

          if [[ -e "$target" || -L "$target" ]]; then
            mv -- "$target" "$session_state/files/$id"
          else
            touch "$session_state/files/$id.absent"
          fi
          copy_hypr_source "$source" "$target"
        done

        dconf dump /org/gnome/desktop/interface/ > "$session_state/dconf-interface.ini"
        dconf reset -f /org/gnome/desktop/interface/
        dconf load /org/gnome/desktop/interface/ < "$hypr_state/dconf-interface.ini"

        touch "$session_state/.active"
      }

      deactivate_hyprland() {
        local index id relative target saved

        initialize_plasma_defaults
        if [[ -e "$session_state/.active" ]]; then
          mkdir -p "$hypr_state/files"
          for index in "''${!managed_ids[@]}"; do
            id="''${managed_ids[$index]}"
            relative="''${managed_paths[$index]}"
            target="$HOME/$relative"
            saved="$session_state/files/$id"

            rm -rf -- "$hypr_state/files/$id"
            if [[ -e "$target" || -L "$target" ]]; then
              mv -- "$target" "$hypr_state/files/$id"
            fi
            if [[ -e "$saved" || -L "$saved" ]]; then
              mkdir -p "$(dirname "$target")"
              mv -- "$saved" "$target"
            fi
          done

          dconf dump /org/gnome/desktop/interface/ > "$hypr_state/dconf-interface.ini"
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
