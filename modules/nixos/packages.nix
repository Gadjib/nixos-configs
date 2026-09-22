{ pkgs, pkgsCodex, ... }:

{
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPreBwrapCmds = ''
        GLOBIGNORE=/vault
        shopt -u dotglob
      '';
      extraLibraries = pkgs': [ pkgs'.faudio ];
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    git
    efibootmgr
    os-prober

    kitty
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.ark
    krita
    thunar
    nwg-look
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    papirus-icon-theme
    bibata-cursors
    pavucontrol
    blueman

    brightnessctl
    playerctl
    pamixer
    upower
    lshw
    pciutils
    usbutils
    android-tools
    smartmontools
    nvme-cli
    lm_sensors
    powertop
    dnsutils
    mtr
    iperf3
    tcpdump
    nmap

    gcc
    gnumake
    cmake
    pkg-config
    nodejs
    python3
    uv
    go
    rustup

    wineWow64Packages.stagingFull
    winetricks
    cabextract
    vulkan-tools
    libva-utils

    pkgsCodex.codex
  ];
}
