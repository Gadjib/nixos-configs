{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Packages added by the interactive `nix-install <pkgname>` helper.
    bitwarden-cli
    discord
    fastfetch
    ffmpeg
    glow
    mpv
    vlc
    stress-ng
    texliveFull
    prismlauncher
    (callPackage ./tlauncher.nix { })
    qbittorrent
    zip
    (callPackage ./spotify.nix { })
    obsidian
    libreoffice-qt6
    openmw
  ];
}
