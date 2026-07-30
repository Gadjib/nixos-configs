{ pkgs, ... }:

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

  networking.hostName = "thinkpad-nix";
  networking.enableIPv6 = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "networkmanager-disable-ipv6" ''
        interface="$1"
        action="$2"

        case "$action" in
          up|pre-up|dhcp6-change|connectivity-change)
            if [ -n "$interface" ] && [ "$interface" != "lo" ]; then
              ${pkgs.procps}/bin/sysctl -q -w "net.ipv6.conf.$interface.disable_ipv6=1" || true
              ${pkgs.iproute2}/bin/ip -6 addr flush dev "$interface" scope global || true
              ${pkgs.iproute2}/bin/ip -6 route flush dev "$interface" || true
            fi
            ;;
        esac
      '';
    }
  ];
  services.resolved.enable = true;

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

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  system.stateVersion = "26.05";
}
