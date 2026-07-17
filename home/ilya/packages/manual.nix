{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Packages added by the interactive `nix-install <pkgname>` helper.
    bitwarden-cli
    discord
    fastfetch
    ffmpeg
    glow
    vlc
    vscode
    stress-ng
    texliveFull
    prismlauncher
    (callPackage ./tlauncher.nix { })
    qbittorrent
    zip
    (callPackage ./spotify.nix { })
  ];
}
