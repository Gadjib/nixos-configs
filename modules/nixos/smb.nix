{ pkgs, ... }:

let
  shares = [ "home" "Downloads" "music" "video" "Store" ];
  mountUnits = map (share: "vault-${share}.mount") shares;
  homeNetwork = pkgs.writeShellApplication {
    name = "home-smb-network";
    runtimeInputs = [ pkgs.networkmanager ];
    text = builtins.readFile ./home-smb-network.sh;
  };
  refresh = pkgs.writeShellScript "home-smb-refresh" ''
    set -eu
    if ${homeNetwork}/bin/home-smb-network; then
      # Queue all units explicitly so a new network event also retries failed
      # mounts when the target itself is already active.
      ${pkgs.systemd}/bin/systemctl --no-block start home-smb.target ${builtins.concatStringsSep " " mountUnits}
    else
      ${pkgs.systemd}/bin/systemctl --no-block stop home-smb.target ${builtins.concatStringsSep " " mountUnits}
    fi
  '';
  dispatcher = pkgs.writeShellScript "home-smb-dispatcher" ''
    case "''${2:-}" in
      up|down|dhcp4-change|reapply)
        # Don't wait for CIFS inside NetworkManager's dispatcher. Restarting
        # the short reconciliation job makes the latest network state win.
        ${pkgs.systemd}/bin/systemctl --no-block restart home-smb-refresh.service
        ;;
    esac
  '';
in
{
  # Native mount units do not infer this as fileSystems entries would.
  boot.supportedFilesystems = [ "cifs" ];
  environment.systemPackages = [ pkgs.cifs-utils ];

  systemd.tmpfiles.rules = [
    "d /vault 0755 root root -"
    "r /mnt/home - - - -"
  ];

  networking.networkmanager.dispatcherScripts = [
    { type = "basic"; source = dispatcher; }
  ];

  systemd.services.home-smb-refresh = {
    description = "Reconcile home SMB mounts with the current Wi-Fi network";
    after = [ "NetworkManager.service" ];
    wants = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = refresh;
      TimeoutStartSec = "10s";
    };
  };

  # Recheck immediately before mounting, including manual unit starts and
  # queued starts after a network change. No RemainAfterExit: never cache access.
  systemd.services.home-smb-network-allowed = {
    description = "Require a connected 0xDEADBEEF Wi-Fi network for SMB";
    after = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${homeNetwork}/bin/home-smb-network";
      TimeoutStartSec = "5s";
    };
  };

  systemd.targets.home-smb = {
    description = "SMB shares on the home Wi-Fi network";
    wants = mountUnits;
  };

  systemd.mounts = map (share: {
    description = "Home SMB share ${share}";
    what = "//192.168.0.10/${share}";
    where = "/vault/${share}";
    type = "cifs";
    options = builtins.concatStringsSep "," [
      "_netdev"
      "credentials=/etc/samba/vault.credentials"
      "vers=3.1.1"
      "iocharset=utf8"
      "uid=1000"
      "gid=100"
      "file_mode=0660"
      "dir_mode=0770"
    ];
    requires = [ "home-smb-network-allowed.service" ];
    after = [ "home-smb-network-allowed.service" ];
    partOf = [ "home-smb.target" ];
    # A busy legacy /vault mount must not turn these mountpoints into remote
    # directories inside the old home share during the first switch.
    unitConfig.ConditionPathIsMountPoint = "!/vault";
    mountConfig = {
      TimeoutSec = "10s";
      DirectoryMode = "0755";
      ForceUnmount = false;
      LazyUnmount = false;
    };
  }) shares;
}
