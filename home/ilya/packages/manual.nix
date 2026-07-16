{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Packages added by the interactive `install <pkgname>` helper.
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
    (callPackage ./incy.nix { })
    qbittorrent
    zip
    spotify
  ];
}
