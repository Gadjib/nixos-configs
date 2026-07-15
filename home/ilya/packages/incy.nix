{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  desktop-file-utils,
  alsa-lib,
  fontconfig,
  freetype,
  libGL,
  libX11,
  libXext,
  libXi,
  libXrender,
  libXtst,
  zlib,
}:

stdenv.mkDerivation {
  pname = "incy";
  version = "3.3.2";

  src = fetchurl {
    url = "https://github.com/INCY-DEV/incy-platforms/releases/download/desktop-v3.3.2/incy-linux-x64-portable.zip";
    hash = "sha256-LbO71ocmoxepZebTVMdSeU2kb2Vha/5FgkxtryvFFgY=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
    desktop-file-utils
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    libGL
    libX11
    libXext
    libXi
    libXrender
    libXtst
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/incy" "$out/bin" "$out/share/applications" "$out/share/icons/hicolor/256x256/apps"
    cp -R . "$out/share/incy/"
    chmod +x "$out/share/incy/bin/incy"

    makeWrapper "$out/share/incy/bin/incy" "$out/bin/incy"
    cp "$out/share/incy/lib/incy.png" "$out/share/icons/hicolor/256x256/apps/incy.png"

    cat > "$out/share/applications/incy.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.5
Name=INCY
GenericName=VPN client
Comment=INCY VPN client
Exec=incy
Icon=incy
Terminal=false
StartupNotify=true
Categories=Network;Security;
Keywords=VPN;VLESS;Proxy;Network;
EOF

    desktop-file-validate "$out/share/applications/incy.desktop"

    runHook postInstall
  '';

  meta = {
    description = "INCY VPN client packaged from the official Linux x64 portable release";
    homepage = "https://github.com/INCY-DEV/incy-platforms";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "incy";
  };
}
