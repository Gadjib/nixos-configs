{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.targets = [ "hyprland-session.target" ];
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 36;
      spacing = 7;
      fixed-center = false;
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ ];
      modules-right = [
        "hyprland/language"
        "custom/power-profile"
        "cpu"
        "memory"
        "custom/cpu-temp"
        "tray"
        "pulseaudio"
        "battery"
        "clock"
        "custom/power"
      ];

      "custom/power" = {
        format = "⏻";
        tooltip = true;
        tooltip-format = "Power menu";
        on-click = "wlogout --protocol layer-shell";
      };
      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{name}{windows:.2}";
        format-window-separator = "";
        window-rewrite-default = " ";
        window-rewrite = {
          "class<kitty>" = " ";
          "class<firefox>" = " ";
          "class<(TelegramDesktop|org\\.telegram\\.desktop)>" = " ";
          "class<([Bb]itwarden)>" = " 󰌾";
          "class<(org\\.qbittorrent\\.qBittorrent|[Qq][Bb]ittorrent)>" = " ";
          "class<([Dd]iscord|discordcanary)>" = " ";
          "class<spotify>" = " ";
          "class<([Vv][Ll][Cc])>" = " ";
          "class<Happ>" = " 󰒍";
          "class<([Cc]ode|code-url-handler)>" = " 󰨞";
          "class<org\\.kde\\.dolphin>" = " ";
          "class<([Tt]hunar)>" = " ";
          "class<[Oo]bsidian>" = " 󰠮";
          "class<([Ss]team|steam_app_.*)>" = " ";
          "class<([Tt][Ll]auncher|Minecraft.*)>" = " ";
          "class<(org\\.prismlauncher\\.PrismLauncher|prismlauncher)>" = " ";
          "class<(com\\.moonlight_stream\\.Moonlight|[Mm]oonlight)>" = " ";
          "class<(openmw|openmw-launcher|openmw-cs|org\\.openmw\\..*)>" = " 󰍳";
          "class<org\\.kde\\.gwenview>" = " ";
          "class<org\\.kde\\.okular>" = " ";
          "class<(org\\.pwmt\\.zathura|[Zz]athura)>" = " ";
          "class<org\\.kde\\.kate>" = " 󰷈";
          "class<org\\.kde\\.ark>" = " ";
          "class<([Ll]ibre[Oo]ffice.*|soffice)>" = " 󰈙";
          "class<pavucontrol>" = " ";
          "class<blueman-manager>" = " ";
          "class<(nwg-look|qt5ct|qt6ct)>" = " ";
          "class<swappy>" = " ";
          "class<org\\.kde\\.plasma-systemmonitor>" = " ";
        };
      };
      "hyprland/window" = {
        max-length = 42;
        separate-outputs = true;
      };
      "hyprland/language" = {
        format = "󰌌 {short}";
      };
      tray = {
        icon-size = 16;
        spacing = 9;
      };
      cpu = {
        format = " {usage}%";
        tooltip = true;
        interval = 2;
      };
      memory = {
        format = " {used:0.1f}G/{total:0.1f}G {percentage}%";
        tooltip-format = "Memory: {used:0.1f}G used / {total:0.1f}G total";
        interval = 2;
      };
      "custom/cpu-temp" = {
        exec = "/home/ilya/.local/bin/waybar-cpu-temp";
        return-type = "json";
        tooltip = true;
        interval = 3;
      };
      clock = {
        format = "{:%d.%m.%y %H:%M}";
        tooltip-format = "{:%Y-%m-%d}";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "pavucontrol";
      };
      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };
      "custom/power-profile" = {
        exec = "/home/ilya/.local/bin/waybar-power-profile";
        return-type = "json";
        interval = 5;
        tooltip = true;
        on-click = "/home/ilya/.local/bin/waybar-power-profile next";
        on-scroll-up = "/home/ilya/.local/bin/waybar-power-profile next";
        on-scroll-down = "/home/ilya/.local/bin/waybar-power-profile prev";
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(36, 39, 58, 0.92);
        color: #cad3f5;
      }

      #workspaces,
      #window,
      #clock,
      #tray,
      #language,
      #cpu,
      #memory,
      #custom-cpu-temp,
      #pulseaudio,
      #battery,
      #custom-power,
      #custom-power-profile {
        padding: 0 10px;
        margin: 4px 0;
        background: rgba(54, 58, 79, 0.86);
        border-radius: 6px;
      }

      #custom-power {
        margin-right: 7px;
        padding: 0 12px;
        color: #ed8796;
      }

      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        padding: 0 6px;
        margin: 0 1px;
        min-width: 22px;
        border: 0;
        border-radius: 6px;
        box-shadow: none;
        color: #a5adcb;
        background: transparent;
        background-image: none;
        text-shadow: none;
      }

      window#waybar.empty #window {
        padding: 0;
        margin: 0;
        min-width: 0;
        background: transparent;
      }

      #workspaces button.active {
        color: #24273a;
        background: #8aadf4;
        background-image: none;
        border-radius: 6px;
      }

      #workspaces button.urgent,
      #battery.critical:not(.charging) {
        color: #24273a;
        background: #ed8796;
      }

      #workspaces button:hover {
        color: #cad3f5;
        background: rgba(91, 96, 120, 0.62);
        background-image: none;
        box-shadow: none;
      }

      #clock {
        color: #f5bde6;
      }

      #pulseaudio {
        color: #a6da95;
      }

      #language {
        color: #f5a97f;
      }

      #cpu {
        color: #8aadf4;
      }

      #memory {
        color: #c6a0f6;
      }

      #custom-cpu-temp {
        color: #eed49f;
      }

      #custom-cpu-temp.critical {
        color: #24273a;
        background: #ed8796;
      }

      #battery {
        color: #eed49f;
      }
    '';
  };

  home.file.".local/bin/waybar-cpu-temp" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      read_temp() {
        local name file
        for name in /sys/class/hwmon/hwmon*/name; do
          [[ -r "$name" ]] || continue
          case "$(cat "$name")" in
            coretemp)
              file="''${name%/name}/temp1_input"
              [[ -r "$file" ]] && cat "$file" && return 0
              ;;
            thinkpad)
              for file in "''${name%/name}"/temp*_label; do
                [[ -r "$file" ]] || continue
                if [[ "$(cat "$file")" == "CPU" ]]; then
                  cat "''${file%_label}_input" && return 0
                fi
              done
              ;;
          esac
        done
        for file in /sys/class/thermal/thermal_zone*/temp; do
          [[ -r "$file" ]] && cat "$file" && return 0
        done
        return 1
      }

      temp_milli="$(read_temp || echo 0)"
      temp_c=$((temp_milli / 1000))
      class=""
      [[ "$temp_c" -ge 85 ]] && class="critical"
      printf '{"text":" %s°C","tooltip":"CPU temperature: %s°C","class":"%s"}\n' "$temp_c" "$temp_c" "$class"
    '';
  };

  home.file.".local/bin/waybar-power-profile" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      profiles=(performance power-saver balanced)

      current="$(powerprofilesctl get 2>/dev/null || echo balanced)"

      set_profile() {
        powerprofilesctl set "$1" >/dev/null 2>&1 || true
      }

      case "''${1:-}" in
        next|prev)
          index=1
          for i in "''${!profiles[@]}"; do
            [[ "''${profiles[$i]}" == "$current" ]] && index="$i"
          done
          if [[ "''${1:-}" == "next" ]]; then
            index=$(((index + 1) % ''${#profiles[@]}))
          else
            index=$(((index + ''${#profiles[@]} - 1) % ''${#profiles[@]}))
          fi
          set_profile "''${profiles[$index]}"
          exit 0
          ;;
      esac

      case "$current" in
        power-saver) text="󰾆"; tooltip="Power saver"; class="power-saver" ;;
        performance) text="󰓅"; tooltip="Performance"; class="performance" ;;
        *) text="󰾅"; tooltip="Balanced"; class="balanced" ;;
      esac

      printf '{"text":"%s","tooltip":"Power profile: %s","class":"%s"}\n' "$text" "$tooltip" "$class"
    '';
  };
}
