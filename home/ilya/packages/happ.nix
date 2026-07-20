{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  zstd,
  alsa-lib,
  e2fsprogs,
  fontconfig,
  freetype,
  libglvnd,
  libgpg-error,
  libX11,
  libxcb,
  openssl,
  qt6,
  zlib,
}:

stdenv.mkDerivation {
  pname = "happ";
  version = "3.1.0";

  src = fetchurl {
    url = "https://github.com/Happ-proxy/happ-desktop/releases/download/3.1.0/Happ.linux.x64.pkg.tar.zst";
    hash = "sha256-ZyNR4RUqtRyKsw2h1XGC6tfkAvAGG2DMnRJgDF8egrU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    zstd
  ];

  buildInputs = [
    alsa-lib
    e2fsprogs
    fontconfig
    freetype
    libglvnd
    libgpg-error
    libX11
    libxcb
    openssl
    qt6.qtwayland
    stdenv.cc.cc.lib
    zlib
  ];

  sourceRoot = ".";
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share" "$out/bin" "$out/share/applications"
    cp -R opt/happ "$out/share/happ"

    makeWrapper "$out/share/happ/bin/Happ" "$out/bin/happ" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ openssl ]}" \
      --unset QT_QPA_PLATFORMTHEME \
      --unset QT_STYLE_OVERRIDE \
      --unset QT_PLUGIN_PATH \
      --unset QML2_IMPORT_PATH \
      --set QT_QPA_PLATFORM "wayland;xcb" \
      --set QT_QUICK_CONTROLS_STYLE Basic \
      --set QT_IM_MODULE compose
    makeWrapper "$out/share/happ/bin/happd" "$out/bin/happd" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ openssl ]}"

    install -Dm644 usr/share/icons/hicolor/256x256/apps/happ.png \
      "$out/share/icons/hicolor/256x256/apps/happ.png"

    sed \
      -e "s|^Exec=.*|Exec=happ %f|" \
      -e "s|^Icon=.*|Icon=happ|" \
      usr/share/applications/Happ.desktop \
      > "$out/share/applications/happ.desktop"

    runHook postInstall
  '';

  meta = {
    description = "Happ Desktop VPN client packaged from the official Linux x64 release";
    homepage = "https://github.com/Happ-proxy/happ-desktop";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "happ";
  };
}
