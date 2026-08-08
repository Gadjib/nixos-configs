{ pkgs, ... }:

let
  happ = pkgs.callPackage ../../home/ilya/packages/happ.nix { };

  secureHappSocket = pkgs.writeShellScript "secure-happd-socket" ''
    set -eu

    attempt=0
    while [ "$attempt" -lt 100 ]; do
      if [ -S /tmp/happd.sock ]; then
        ${pkgs.coreutils}/bin/chown root:users /tmp/happd.sock
        ${pkgs.coreutils}/bin/chmod 0660 /tmp/happd.sock
        exit 0
      fi

      attempt=$((attempt + 1))
      ${pkgs.coreutils}/bin/sleep 0.05
    done

    echo "happd did not create /tmp/happd.sock within 5 seconds" >&2
    exit 1
  '';
in
{
  environment.systemPackages = [
    happ
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/dbus 0755 root root - -"
    "L+ /var/lib/dbus/machine-id - - - - /etc/machine-id"
  ];

  systemd.services.happd = {
    description = "Happ Process Control Daemon";
    wants = [
      "network-online.target"
      "systemd-resolved.service"
    ];
    after = [
      "network-online.target"
      "systemd-resolved.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "users";
      ExecStart = "${happ}/bin/happd";
      ExecStartPost = secureHappSocket;
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";

      # Happ needs root-level networking and cross-user process inspection for
      # TUN mode and per-application routing, but it does not need unrestricted
      # access to the kernel or the rest of the host filesystem.
      NoNewPrivileges = true;
      CapabilityBoundingSet = [
        "CAP_CHOWN"
        "CAP_DAC_OVERRIDE"
        "CAP_DAC_READ_SEARCH"
        "CAP_FOWNER"
        "CAP_KILL"
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_RAW"
        "CAP_SETGID"
        "CAP_SETUID"
        "CAP_SYS_CHROOT"
        "CAP_SYS_NICE"
        "CAP_SYS_PTRACE"
        "CAP_SYS_RESOURCE"
      ];
      UMask = "0007";

      StateDirectory = "happd";
      StateDirectoryMode = "0700";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "/tmp" ];
      PrivateTmp = false;

      DevicePolicy = "closed";
      DeviceAllow = [ "/dev/net/tun rw" ];
      ProtectControlGroups = true;
      ProtectKernelLogs = true;
      ProtectClock = true;
      ProtectHostname = true;
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_PACKET"
      ];
    };
  };
}
