{
  fileSystems."/mnt/win_c" = {
    device = "/dev/disk/by-uuid/32566001565FC3EF";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "umask=022"
      "windows_names"
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
    ];
  };
}
