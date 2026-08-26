{
  # The systemd initrd discovers the ext4 swapfile and its physical offset
  # from systemd's HibernateLocation EFI variable. This avoids pinning an
  # offset that would become invalid if the swapfile were ever recreated.
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = true;
    AllowSuspendThenHibernate = true;
    SuspendState = "mem";
    MemorySleepMode = "deep";
    HibernateState = "disk";
    HibernateMode = "platform";
    HibernateDelaySec = "2h";
    HibernateOnACPower = true;
  };
}
