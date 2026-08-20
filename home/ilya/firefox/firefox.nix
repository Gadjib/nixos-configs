{
  lib,
  pkgs,
  ...
}:

let
  firefoxBinary = "${pkgs.firefox}/bin/firefox";
  sharedLauncher = "/home/ilya/.local/bin/firefox-shared";

  registerSharedProfile = pkgs.writeShellApplication {
    name = "register-shared-firefox-profile";
    runtimeInputs = with pkgs; [
      coreutils
      python3
    ];
    text = ''
      set -euo pipefail

      firefox_root="$HOME/.mozilla/firefox"
      profiles_ini="$firefox_root/profiles.ini"
      installs_ini="$firefox_root/installs.ini"
      backup_root="$HOME/.local/state/nixos-desktop-isolation/backups"
      mimeapps="$HOME/.config/mimeapps.list"
      userapp_backup="$backup_root/firefox-userapps-before-sharing"

      mkdir -p "$firefox_root" "$backup_root"
      if [[ ! -d "$firefox_root/hyprland" ]]; then
        printf 'register-shared-firefox-profile: canonical profile is missing: %s\n' \
          "$firefox_root/hyprland" >&2
        exit 1
      fi
      if [[ -f "$profiles_ini" && ! -e "$backup_root/firefox-profiles-before-sharing.ini" ]]; then
        cp -- "$profiles_ini" "$backup_root/firefox-profiles-before-sharing.ini"
      fi
      if [[ -s "$installs_ini" && ! -e "$backup_root/firefox-installs-before-sharing.ini" ]]; then
        cp -- "$installs_ini" "$backup_root/firefox-installs-before-sharing.ini"
      fi
      if [[ -f "$mimeapps" && ! -e "$backup_root/firefox-mimeapps-before-sharing.list" ]]; then
        cp -- "$mimeapps" "$backup_root/firefox-mimeapps-before-sharing.list"
      fi

      python3 - "$profiles_ini" "$installs_ini" "$mimeapps" <<'PY'
      import configparser
      import os
      import re
      import sys
      import tempfile
      from pathlib import Path

      profiles_path = Path(sys.argv[1])
      installs_path = Path(sys.argv[2])
      mimeapps_path = Path(sys.argv[3])
      shared_path = "hyprland"

      def read_ini(path):
          parser = configparser.ConfigParser(interpolation=None)
          parser.optionxform = str
          if path.exists() and path.stat().st_size:
              parser.read(path)
          return parser

      def write_ini(path, parser):
          path.parent.mkdir(parents=True, exist_ok=True)
          with tempfile.NamedTemporaryFile(
              mode="w", dir=path.parent, prefix=f".{path.name}.", delete=False
          ) as handle:
              parser.write(handle, space_around_delimiters=False)
              temporary = Path(handle.name)
          os.chmod(temporary, 0o600)
          os.replace(temporary, path)

      profiles = read_ini(profiles_path)
      shared_section = None
      highest_index = -1
      for section in profiles.sections():
          match = re.fullmatch(r"Profile(\d+)", section)
          if not match:
              continue
          highest_index = max(highest_index, int(match.group(1)))
          if profiles[section].get("Path") == shared_path:
              shared_section = section

      if shared_section is None:
          shared_section = f"Profile{highest_index + 1}"
          profiles[shared_section] = {
              "Name": "shared",
              "IsRelative": "1",
              "Path": shared_path,
          }

      for section in profiles.sections():
          if re.fullmatch(r"Profile\d+", section):
              profiles[section].pop("Default", None)
      profiles[shared_section]["Default"] = "1"

      if "General" not in profiles:
          profiles["General"] = {}
      profiles["General"]["StartWithLastProfile"] = "1"
      profiles["General"]["Version"] = "2"
      write_ini(profiles_path, profiles)

      if installs_path.exists() and installs_path.stat().st_size:
          installs = read_ini(installs_path)
          for section in installs.sections():
              installs[section]["Default"] = shared_path
              installs[section]["Locked"] = "1"
          write_ini(installs_path, installs)

      web_mime_types = (
          "application/x-extension-htm",
          "application/x-extension-html",
          "application/x-extension-shtml",
          "application/x-extension-xht",
          "application/x-extension-xhtml",
          "application/xhtml+xml",
          "text/html",
          "x-scheme-handler/chrome",
          "x-scheme-handler/http",
          "x-scheme-handler/https",
      )
      mimeapps = read_ini(mimeapps_path)
      for section in ("Added Associations", "Default Applications"):
          if section not in mimeapps:
              mimeapps[section] = {}
          for mime_type in web_mime_types:
              mimeapps[section][mime_type] = "firefox.desktop;"
      write_ini(mimeapps_path, mimeapps)
      PY

      mkdir -p "$userapp_backup"
      shopt -s nullglob
      for desktop_file in "$HOME/.local/share/applications"/userapp-Firefox-*.desktop; do
        mv --backup=numbered -- "$desktop_file" "$userapp_backup/"
      done
    '';
  };
in
{
  home.file = {
    ".local/bin/firefox-shared" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        profile_root="$HOME/.mozilla/firefox/hyprland"

        if [[ "''${XDG_CURRENT_DESKTOP:-}" == *Hyprland* ]] \
          && (( $# > 0 )) \
          && ${pkgs.hyprland}/bin/hyprctl -j clients \
            | ${pkgs.jq}/bin/jq -e 'any(.[]; .class == "firefox")' >/dev/null; then
          ${firefoxBinary} --profile "$profile_root" "$@"
          ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow 'class:^(firefox)$' >/dev/null
          exit 0
        fi

        exec ${firefoxBinary} --profile "$profile_root" "$@"
      '';
    };

    ".local/bin/firefox-hyprland" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        exec ${sharedLauncher} "$@"
      '';
    };

    # Firefox reads user.js but does not use it for mutable profile data.
    # Keeping these two existing Hyprland preferences declarative makes the
    # shared profile render identically before session-specific CSS is loaded.
    ".mozilla/firefox/hyprland/user.js" = {
      force = true;
      text = ''
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
        user_pref("browser.tabs.inTitlebar", 1);
      '';
    };
  };

  home.activation.registerSharedFirefoxProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${registerSharedProfile}/bin/register-shared-firefox-profile
  '';

  programs.fish.shellAliases.firefox = sharedLauncher;

  xdg.desktopEntries = {
    # One canonical desktop ID is essential: Firefox's Linux default-browser
    # check expects firefox.desktop. Session-specific UI is handled by CSS,
    # not by a second desktop entry.
    firefox = {
      name = "Firefox";
      genericName = "Web Browser";
      exec = "${sharedLauncher} --name firefox %U";
      icon = "firefox";
      terminal = false;
      startupNotify = true;
      categories = [
        "Network"
        "WebBrowser"
      ];
      settings = {
        StartupWMClass = "firefox";
      };
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        new-private-window = {
          name = "New Private Window";
          exec = "${sharedLauncher} --private-window %U";
        };
        new-window = {
          name = "New Window";
          exec = "${sharedLauncher} --new-window %U";
        };
      };
    };
  };
}
