{
  home.file.".local/bin/firefox-hyprland" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      profile_root="$HOME/.mozilla/firefox/hyprland"
      chrome_dir="$profile_root/chrome"

      mkdir -p "$chrome_dir"

      cat > "$profile_root/user.js" <<'EOF'
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      user_pref("browser.tabs.inTitlebar", 1);
      EOF

      cat > "$chrome_dir/userChrome.css" <<'EOF'
      @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

      .titlebar-buttonbox-container,
      .titlebar-buttonbox,
      .titlebar-button {
        display: none !important;
      }

      #TabsToolbar .titlebar-spacer {
        display: none !important;
      }
      EOF

      if (( $# > 0 )) && hyprctl -j clients \
        | jq -e 'any(.[]; .class == "firefox")' >/dev/null; then
        firefox --profile "$profile_root" "$@"
        hyprctl dispatch focuswindow 'class:^(firefox)$' >/dev/null
        exit 0
      fi

      exec firefox --profile "$profile_root" "$@"
    '';
  };

  xdg.desktopEntries.firefox-hyprland = {
    name = "Firefox Hyprland";
    genericName = "Web Browser";
    exec = "/home/ilya/.local/bin/firefox-hyprland %U";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    settings.OnlyShowIn = "Hyprland;";
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/xml"
      "application/rss+xml"
      "application/rdf+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
}
