{ pkgs, ... }:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  environment.systemPackages = with pkgs; [
    avahi
    cifs-utils
  ];

  fileSystems."/mnt/home" = {
    device = "//vault.local/home";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=10min"
      "_netdev"
      "nofail"
      "credentials=/etc/samba/vault.credentials"
      "vers=3.1.1"
      "iocharset=utf8"
      "uid=1000"
      "gid=100"
      "file_mode=0660"
      "dir_mode=0770"
    ];
  };
}
