{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
  desktop-file-utils,
  jre,
}:

stdenvNoCC.mkDerivation {
  pname = "tlauncher";
  version = "2026-01-06";

  src = fetchurl {
    url = "https://tlauncher.org/jar";
    hash = "sha256-xht2qWiXbOi6ezHziEcSVCxN6BPKDG8yQZSvULnLRW8=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
    desktop-file-utils
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/tlauncher" "$out/bin" "$out/share/applications"
    unzip -j "$src" TLauncher.jar -d "$out/share/tlauncher"

    makeWrapper ${jre}/bin/java "$out/bin/tlauncher" \
      --add-flags "-jar $out/share/tlauncher/TLauncher.jar"

    cat > "$out/share/applications/tlauncher.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Version=1.5
Name=TLauncher
GenericName=Minecraft launcher
Comment=TLauncher Minecraft launcher
Exec=tlauncher
Icon=applications-games
Terminal=false
StartupNotify=true
StartupWMClass=TLauncher
Categories=Game;
Keywords=Minecraft;Launcher;Game;
EOF

    desktop-file-validate "$out/share/applications/tlauncher.desktop"

    runHook postInstall
  '';

  meta = {
    description = "TLauncher Minecraft launcher packaged from the official jar endpoint";
    homepage = "https://tlauncher.org/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "tlauncher";
  };
}
