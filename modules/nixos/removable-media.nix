{
  services.udisks2.enable = true;

  # Restore normal permissions after retiring user-managed USB links in /mnt.
  # Removable filesystems are mounted by UDisks below /run/media/ilya.
  systemd.tmpfiles.rules = [ "d /mnt 0755 root root -" ];
}
