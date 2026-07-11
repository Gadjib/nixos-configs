{ pkgs, ... }:

{
  programs.firefox.enable = true;

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

    codex
  ];
}
