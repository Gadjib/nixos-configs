{ pkgs, ... }:

let
  happ = pkgs.callPackage ../../home/ilya/packages/happ.nix { };
  xrayTunBypass = pkgs.writeShellScript "happ-xray-tun-bypass" ''
    set -uo pipefail

    log() {
      printf '%s\n' "$*"
    }

    default_route() {
      ${pkgs.iproute2}/bin/ip -4 route show default 0.0.0.0/0 \
        | ${pkgs.gawk}/bin/awk '
          {
            for (i = 1; i <= NF; i++) {
              if ($i == "via") gateway = $(i + 1)
              if ($i == "dev") device = $(i + 1)
              if ($i == "src") source = $(i + 1)
            }
            if (gateway != "" && device != "" && source != "") {
              print gateway, device, source
              exit
            }
          }
        '
    }

    route_targets() {
      ${pkgs.iproute2}/bin/ss -Htanp \
        | ${pkgs.gawk}/bin/awk '
          $0 ~ /users:\(\("(xray|Happ)"/ && $4 ~ /^172[.]18[.]/ {
            remote = $5
            gsub(/^\[/, "", remote)
            sub(/\].*/, "", remote)
            sub(/:[0-9]+$/, "", remote)
            if (remote ~ /^[0-9.]+$/) print remote
          }
        ' \
        | ${pkgs.coreutils}/bin/sort -u
    }

    while true; do
      read -r gateway device source < <(default_route)

      if [ -n "''${gateway:-}" ] && [ -n "''${device:-}" ] && [ -n "''${source:-}" ]; then
        route_targets | while read -r target; do
          [ -n "$target" ] || continue

          case "$target" in
            0.*|10.*|127.*|169.254.*|172.16.*|172.17.*|172.18.*|172.19.*|172.2[0-9].*|172.3[0-1].*|192.168.*)
              continue
              ;;
          esac

          if ${pkgs.iproute2}/bin/ip route replace "$target/32" via "$gateway" dev "$device" src "$source" table 2022; then
            log "routed $target/32 via $gateway dev $device src $source in table 2022"
          fi
        done
      fi

      sleep 1
    done
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
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = false;
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";
    };
  };

  systemd.services.happ-xray-tun-bypass = {
    description = "Keep Happ/Xray control connections outside the sing-box TUN";
    wants = [
      "network-online.target"
      "happd.service"
    ];
    after = [
      "network-online.target"
      "happd.service"
    ];
    partOf = [ "happd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${xrayTunBypass}";
      Restart = "always";
      RestartSec = "1s";
    };
  };
}
