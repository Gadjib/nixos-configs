{ pkgs, ... }:

let
  appearance = import ../appearance.nix { inherit pkgs; };
  wallpaper = ../../../assets/wallpapers/wallhaven-2eqpzm.png;
in

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$launcher" = "rofi -show drun";
      "$fileManager" = "dolphin";
      "$browser" = "/home/ilya/.local/bin/firefox-hyprland";

      monitor = [
        ",preferred,auto,${toString appearance.scale}"
      ];

      env = [
        "XCURSOR_THEME,${appearance.cursor.name}"
        "XCURSOR_SIZE,${toString appearance.cursor.size}"
        "HYPRCURSOR_THEME,${appearance.cursor.name}"
        "HYPRCURSOR_SIZE,${toString appearance.cursor.size}"
      ];

      exec-once = [
        "waybar"
        "mako"
        "awww-daemon"
        "sleep 0.5 && awww img ${wallpaper} --resize crop --transition-type fade --transition-duration 1"
        "hypridle"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "swayosd-server"
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          "tap-to-click" = true;
          tap_button_map = "lrm";
          "tap-and-drag" = true;
          drag_lock = 0;
          drag_3fg = 0;
          disable_while_typing = false;
          clickfinger_behavior = true;
          middle_button_emulation = false;
          scroll_factor = 0.85;
        };
        sensitivity = 0;
      };

      gestures = {
        workspace_swipe_distance = 300;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 25;
        workspace_swipe_cancel_ratio = 0.4;
        workspace_swipe_create_new = true;
        workspace_swipe_direction_lock = true;
        workspace_swipe_direction_lock_threshold = 10;
        workspace_swipe_forever = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(8aadf4ee) rgba(c6a0f6ee) 45deg";
        "col.inactive_border" = "rgba(363a4faa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 14;
          render_power = 3;
          color = "rgba(181926ee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
        ];
        animation = [
          "windows,1,4,easeOutQuint"
          "windowsOut,1,3,easeInOutCubic"
          "border,1,6,easeOutQuint"
          "fade,1,4,easeOutQuint"
          "workspaces,1,4,easeOutQuint"
        ];
      };

      dwindle = {
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };

      xwayland = {
        force_zero_scaling = true;
        use_nearest_neighbor = false;
      };

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $launcher"
        "$mod, Q, killactive"
        "$mod, M, exec, wlogout"
        "$mod, E, exec, $fileManager"
        "$mod, B, exec, $browser"
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
        "$mod, V, exec, cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy --type image/png"
        "SHIFT, Print, exec, grim - | wl-copy --type image/png"
        "CTRL, Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "CTRL SHIFT, Print, exec, grim - | swappy -f -"

        "$mod, F, fullscreen"
        "$mod, Space, togglefloating"
        "$mod, P, pseudo"
        "$mod, O, layoutmsg, togglesplit"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod CTRL, 1, workspace, 11"
        "$mod CTRL, 2, workspace, 12"
        "$mod CTRL, 3, workspace, 13"
        "$mod CTRL, 4, workspace, 14"
        "$mod CTRL, 5, workspace, 15"
        "$mod CTRL, 6, workspace, 16"
        "$mod CTRL, 7, workspace, 17"
        "$mod CTRL, 8, workspace, 18"
        "$mod CTRL, 9, workspace, 19"
        "$mod CTRL, 0, workspace, 20"
        "$mod CTRL SHIFT, 1, movetoworkspace, 11"
        "$mod CTRL SHIFT, 2, movetoworkspace, 12"
        "$mod CTRL SHIFT, 3, movetoworkspace, 13"
        "$mod CTRL SHIFT, 4, movetoworkspace, 14"
        "$mod CTRL SHIFT, 5, movetoworkspace, 15"
        "$mod CTRL SHIFT, 6, movetoworkspace, 16"
        "$mod CTRL SHIFT, 7, movetoworkspace, 17"
        "$mod CTRL SHIFT, 8, movetoworkspace, 18"
        "$mod CTRL SHIFT, 9, movetoworkspace, 19"
        "$mod CTRL SHIFT, 0, movetoworkspace, 20"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
      ];

      gesture = [
        "3, horizontal, workspace"
        "4, horizontal, workspace"
        "4, down, special, magic"
        "4, up, fullscreen"
        "3, pinchin, float"
        "4, pinchout, cursorZoom, 2"
        "4, pinchin, cursorZoom, 1"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      bindl = [
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = [
        "match:class ^(pavucontrol)$, float on"
        "match:class ^(blueman-manager)$, float on"
        "match:class ^(firefox)$, workspace 2"
        "match:title ^(Picture-in-Picture)$, float on"
        "match:title ^(Picture-in-Picture)$, pin on"
      ];
    };
  };

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
      timeout = 300
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 600
      on-timeout = hyprctl dispatch dpms off
      on-resume = hyprctl dispatch dpms on
    }
  '';

  xdg.configFile."hypr/hyprlock.conf".text = ''
    background {
      color = rgba(24273aff)
    }

    input-field {
      size = 280, 56
      outline_thickness = 2
      dots_size = 0.25
      dots_spacing = 0.25
      outer_color = rgba(8aadf4ff)
      inner_color = rgba(363a4fff)
      font_color = rgba(cad3f5ff)
      fade_on_empty = false
      placeholder_text = Password
      position = 0, -40
      halign = center
      valign = center
    }
  '';

  systemd.user.services.lock-before-sleep = {
    Unit = {
      Description = "Lock the session before system sleep";
      Before = [ "sleep.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/loginctl lock-session";
    };
    Install.WantedBy = [ "sleep.target" ];
  };

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "NetworkManager tray applet";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Bluetooth tray applet";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
