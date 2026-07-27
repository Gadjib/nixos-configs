{ pkgs, ... }:

let
  homeSmbAvailable = pkgs.writeShellApplication {
    name = "home-smb-available";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      iputils
      networkmanager
    ];
    text = ''
      required_ssid="0xDEADBEEF48"
      server="192.168.0.10"
      state_dir="''${HOME_SMB_STATE_DIR:-/run/home-smb-preflight}"
      state_file="$state_dir/current"

      active_wifi="$(
        LC_ALL=C nmcli --wait 1 --terse --fields DEVICE,ACTIVE,SSID \
          device wifi list --rescan no |
          awk -F: '$2 == "yes" { print; exit }'
      )"
      wifi_device="''${active_wifi%%:*}"
      active_ssid="''${active_wifi#*:yes:}"

      if [[ -n "$active_wifi" && "$active_ssid" == "$required_ssid" ]]; then
        printf 'SMB preflight: home Wi-Fi is active; allowing direct CIFS attempt\n'
        exit 0
      fi

      if [[ -n "$wifi_device" ]]; then
        connection_path="$(
          LC_ALL=C nmcli --wait 1 --get-values GENERAL.CON-PATH \
            device show "$wifi_device"
        )"
        session_id="''${connection_path##*/}"
      else
        session_id="no-active-wifi"
      fi

      if [[ -z "$session_id" || ! "$session_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
        printf 'SMB preflight: cannot identify the active network session\n' >&2
        exit 1
      fi

      mkdir -p "$state_dir"
      if [[ -r "$state_file" ]]; then
        read -r cached_session cached_result < "$state_file" || true
        if [[ "''${cached_session:-}" == "$session_id" ]]; then
          case "''${cached_result:-}" in
            reachable)
              printf 'SMB preflight: reusing successful probe for session %s\n' \
                "$session_id"
              exit 0
              ;;
            unreachable)
              printf 'SMB preflight: probe already failed for session %s; not retrying\n' \
                "$session_id" >&2
              exit 1
              ;;
          esac
        fi
      fi

      ping_args=( -n -c 1 -W 1 -w 1 )
      if [[ -n "$wifi_device" ]]; then
        ping_args+=( -I "$wifi_device" )
      fi

      if ping "''${ping_args[@]}" "$server"; then
        printf '%s reachable\n' "$session_id" > "$state_file"
        exit 0
      fi

      printf '%s unreachable\n' "$session_id" > "$state_file"
      printf 'SMB preflight: %s did not answer the one allowed ping for session %s\n' \
        "$server" "$session_id" >&2
      exit 1
    '';
  };
in

{
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  systemd.tmpfiles.rules = [
    "d /vault 0755 root root -"
    "r /mnt/home - - - -"
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

  fileSystems."/vault" = {
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
