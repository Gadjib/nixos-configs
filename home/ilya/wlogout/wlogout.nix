{
  xdg.configFile."wlogout/layout".text = ''
    {
      "label" : "lock",
      "action" : "loginctl lock-session",
      "text" : "Lock",
      "keybind" : "l"
    }
    {
      "label" : "logout",
      "action" : "hyprctl dispatch exit",
      "text" : "Logout",
      "keybind" : "e"
    }
    {
      "label" : "suspend",
      "action" : "systemctl suspend",
      "text" : "Suspend",
      "keybind" : "s"
    }
    {
      "label" : "reboot",
      "action" : "systemctl reboot",
      "text" : "Reboot",
      "keybind" : "r"
    }
    {
      "label" : "shutdown",
      "action" : "systemctl poweroff",
      "text" : "Shutdown",
      "keybind" : "p"
    }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * {
      background-image: none;
      box-shadow: none;
      font-family: "JetBrainsMono Nerd Font", "Inter", sans-serif;
      font-size: 15px;
    }

    window {
      background-color: rgba(24, 25, 38, 0.54);
    }

    button {
      margin: 10px;
      border: 2px solid rgba(138, 173, 244, 0.45);
      border-radius: 8px;
      background-color: rgba(36, 39, 58, 0.80);
      background-repeat: no-repeat;
      background-position: center 34%;
      background-size: 34px;
      color: #cad3f5;
    }

    button:focus {
      border-color: rgba(138, 173, 244, 0.45);
      background-color: rgba(36, 39, 58, 0.80);
      color: #cad3f5;
    }

    button:active,
    button:hover {
      border-color: #8aadf4;
      background-color: rgba(54, 58, 79, 0.88);
      color: #ffffff;
    }

    #lock {
      background-image: image(url("/etc/profiles/per-user/ilya/share/wlogout/icons/lock.png"));
    }

    #logout {
      background-image: image(url("/etc/profiles/per-user/ilya/share/wlogout/icons/logout.png"));
    }

    #suspend {
      background-image: image(url("/etc/profiles/per-user/ilya/share/wlogout/icons/suspend.png"));
    }

    #reboot {
      background-image: image(url("/etc/profiles/per-user/ilya/share/wlogout/icons/reboot.png"));
    }

    #shutdown {
      background-image: image(url("/etc/profiles/per-user/ilya/share/wlogout/icons/shutdown.png"));
    }
  '';
}
