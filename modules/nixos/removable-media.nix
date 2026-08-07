{
  services.udisks2.enable = true;

  # Udisks mounts removable media as the active user below /run/media.  The
  # users group needs write access here only to maintain compatibility links;
  # the actual filesystems are never mounted directly below /mnt.
  systemd.tmpfiles.rules = [ "d /mnt 0775 root users -" ];
}
