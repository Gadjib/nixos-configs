{ pkgs, ... }:

let
  nmcli = "${pkgs.networkmanager}/bin/nmcli";

  disableNetworkManagerIPv6 = pkgs.writeShellScript "networkmanager-disable-ipv6" ''
    set -u
    export LC_ALL=C

    interface="''${1:-}"
    action="''${2:-}"
    connection_uuid="''${CONNECTION_UUID:-}"

    case "$action" in
      up|vpn-up)
        ;;
      *)
        exit 0
        ;;
    esac

    if [ -z "$connection_uuid" ] || [ -z "$interface" ] || [ "$interface" = "lo" ]; then
      exit 0
    fi

    connection_type="$(${nmcli} -g connection.type connection show uuid "$connection_uuid" 2>/dev/null)" || exit 0
    if [ "$connection_type" = "loopback" ]; then
      exit 0
    fi

    ipv6_method="$(${nmcli} -g ipv6.method connection show uuid "$connection_uuid" 2>/dev/null)" || ipv6_method=""
    if [ "$ipv6_method" != "disabled" ]; then
      ${nmcli} connection modify uuid "$connection_uuid" ipv6.method disabled
      ${nmcli} device modify "$interface" ipv6.method disabled || true
    fi
  '';
in
{
  imports = [
    ../../hardware-configuration.nix
    ../../modules/nixos/compat.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/happ.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/removable-media.nix
    ../../modules/nixos/smb.nix
    ../../modules/nixos/swap.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/windows.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    configurationLimit = 10;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "ipv6.disable=1" ];

  networking.hostName = "thinkpad-nix";
  networking.enableIPv6 = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = disableNetworkManagerIPv6;
    }
  ];
  services.resolved.enable = true;

  systemd.services.networkmanager-disable-ipv6-profiles = {
    description = "Disable IPv6 in all NetworkManager connection profiles";
    requires = [ "NetworkManager.service" ];
    after = [ "NetworkManager.service" ];
    before = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.networkmanager ];
    script = ''
      set -u
      export LC_ALL=C

      while IFS=: read -r connection_uuid connection_type; do
        if [ -z "$connection_uuid" ] || [ "$connection_type" = "loopback" ]; then
          continue
        fi

        ipv6_method="$(${nmcli} -g ipv6.method connection show uuid "$connection_uuid" 2>/dev/null)" || ipv6_method=""
        if [ "$ipv6_method" != "disabled" ]; then
          ${nmcli} connection modify uuid "$connection_uuid" ipv6.method disabled
        fi
      done < <(${nmcli} -t -f UUID,TYPE connection show)

      while IFS=: read -r interface connection_uuid; do
        if [ -z "$connection_uuid" ] || [ -z "$interface" ] || [ "$interface" = "lo" ]; then
          continue
        fi

        ${nmcli} device modify "$interface" ipv6.method disabled || true
      done < <(${nmcli} -t -f DEVICE,UUID connection show --active)
    '';
    serviceConfig.Type = "oneshot";
  };

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
