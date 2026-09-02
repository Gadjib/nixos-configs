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
      Group = "root";
      ExecStart = "${happ}/bin/happd";
      ExecStartPost = secureHappSocket;
      Restart = "always";
      RestartSec = "5s";
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";

      # Upstream explicitly requires an unrestricted privileged daemon: happd
      # launches and supervises sing-box/Xray processes that configure TUN,
      # policy routing and DNS. NoNewPrivileges or a strict systemd sandbox is
      # incompatible with those privileged child processes.
      NoNewPrivileges = false;
      StateDirectory = "happd";
      StateDirectoryMode = "0700";
    };
  };
}
