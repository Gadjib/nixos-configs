{
  lib,
  symlinkJoin,
  makeWrapper,
  spotify,
}:

symlinkJoin {
  name = "spotify-hyprland-${spotify.version or "wrapped"}";
  paths = [ spotify ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    rm -f "$out/bin/spotify"
    makeWrapper "${spotify}/bin/spotify" "$out/bin/spotify" \
      --set NIXOS_OZONE_WL 1 \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--force-device-scale-factor=1.25"

    if [ -f "$out/share/applications/spotify.desktop" ]; then
      rm -f "$out/share/applications/spotify.desktop"
      install -Dm0644 "${spotify}/share/applications/spotify.desktop" "$out/share/applications/spotify.desktop"
      substituteInPlace "$out/share/applications/spotify.desktop" \
        --replace-fail "Exec=spotify %U" "Exec=$out/bin/spotify %U"
    fi
  '';

  meta = spotify.meta // {
    description = "${spotify.meta.description or "Spotify"} wrapped for crisp Hyprland HiDPI rendering";
    mainProgram = "spotify";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
  };
}
