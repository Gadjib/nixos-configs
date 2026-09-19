{ config, lib, ... }:

{
  # UDisks owns the target directory and creates it when a device is mounted.
  home.file."media".source = config.lib.file.mkOutOfStoreSymlink "/run/media/ilya";

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    settings = {
      device_config = [
        {
          id_usage = "filesystem";
          options = [
            "nosuid"
            "nodev"
            "noexec"
          ];
        }
      ];
    };
  };

  systemd.user.services.udiskie = {
    Unit = {
      # Home Manager normally orders udiskie after tray.target. Here both
      # udiskie and Waybar are members of hyprland-session.target, so that
      # ordering would create a target cycle. Udiskie's status notifier can
      # register before Waybar and appear when the tray becomes available.
      After = lib.mkForce [ ];
      Requires = lib.mkForce [ ];
      PartOf = lib.mkForce [ "hyprland-session.target" ];
    };
    Service = {
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
  };
}
