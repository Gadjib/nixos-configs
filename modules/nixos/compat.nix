{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      atk
      cairo
      cups
      dbus
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libX11
      libXScrnSaver
      libXcursor
      libXext
      libXi
      libXrandr
      libXrender
      libXtst
      libpulseaudio
      pango
      stdenv.cc.cc
      libxcb
      zlib
    ];
  };
}
