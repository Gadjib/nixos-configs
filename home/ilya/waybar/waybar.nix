{
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 36;
      spacing = 7;
      fixed-center = true;
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [
        "hyprland/language"
        "power-profiles-daemon"
        "cpu"
        "memory"
        "temperature"
        "tray"
        "pulseaudio"
        "battery"
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
        format = "{name}";
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
      temperature = {
        format = " {temperatureC}°C";
        critical-threshold = 85;
        tooltip = true;
        interval = 3;
      };
      clock = {
        format = "{:%a %d %b  %H:%M}";
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
      power-profiles-daemon = {
        format = "{icon}";
        tooltip-format = "Power profile: {profile}";
        format-icons = {
          default = "󰾆";
          performance = "󰓅";
          balanced = "󰾆";
          power-saver = "󰾅";
        };
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
      #temperature,
      #pulseaudio,
      #battery,
      #custom-power,
      #power-profiles-daemon {
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

      #workspaces button {
        padding: 0 8px;
        margin: 0 2px;
        min-width: 24px;
        border: 0;
        border-radius: 6px;
        box-shadow: none;
        color: #a5adcb;
        background: transparent;
        background-image: none;
        text-shadow: none;
      }

      #window.empty {
        padding: 0;
        margin: 0;
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

      #temperature {
        color: #eed49f;
      }

      #temperature.critical {
        color: #24273a;
        background: #ed8796;
      }

      #battery {
        color: #eed49f;
      }
    '';
  };
}
