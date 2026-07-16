{ pkgs, ... }:

let
  happ = pkgs.callPackage ../../home/ilya/packages/happ.nix { };
in
{
  environment.systemPackages = [
    happ
  ];

  systemd.services.happd = {
    description = "Happ Process Control Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      ExecStart = "${happ}/share/happ/bin/happd";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = false;
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";
    };
  };
}
