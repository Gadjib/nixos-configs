{ pkgs, ... }:

let
  happ = pkgs.callPackage ../../home/ilya/packages/happ.nix { };
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
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      ExecStart = "${happ}/bin/happd";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = false;
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";
    };
  };
}
