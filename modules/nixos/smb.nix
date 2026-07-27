{ pkgs, ... }:

let
  homeSmbAvailable = pkgs.writeShellApplication {
    name = "home-smb-available";
    runtimeInputs = with pkgs; [
      gawk
      iputils
      networkmanager
    ];
    text = ''
      required_ssid="0xDEADBEEF48"
      server="192.168.0.10"

      wifi_device="$(
        LC_ALL=C nmcli --wait 1 --terse --fields DEVICE,ACTIVE,SSID \
          device wifi list --rescan no |
          awk -F: -v ssid="$required_ssid" \
            '$2 == "yes" && $3 == ssid { print $1; exit }'
      )"

      if [[ -z "$wifi_device" ]]; then
        printf 'SMB preflight: active Wi-Fi is not %s; skipping %s\n' \
          "$required_ssid" "$server" >&2
        exit 1
      fi

      if ! ping -n -c 1 -W 1 -w 1 -I "$wifi_device" "$server"; then
        printf 'SMB preflight: %s did not answer the first ping on %s\n' \
          "$server" "$wifi_device" >&2
        exit 1
      fi
    '';
  };
in

{
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  systemd.services.home-smb-available = {
    description = "Check home Wi-Fi and SMB server reachability";
    after = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${homeSmbAvailable}/bin/home-smb-available";
      TimeoutStartSec = "3s";
    };
  };

  fileSystems."/mnt/home" = {
    device = "//192.168.0.10/home";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "x-systemd.requires=home-smb-available.service"
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
