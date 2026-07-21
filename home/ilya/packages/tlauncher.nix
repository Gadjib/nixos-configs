{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  runtimeShell,
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
    desktop-file-utils
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/tlauncher" "$out/bin" "$out/share/applications"
    unzip -j "$src" TLauncher.jar -d "$out/share/tlauncher"

    cat > "$out/bin/tlauncher" <<EOF
#!${runtimeShell}
set -euo pipefail

runtime_dir="\''${XDG_DATA_HOME:-\$HOME/.local/share}/tlauncher"
runtime_jar="\$runtime_dir/TLauncher.jar"
store_jar="$out/share/tlauncher/TLauncher.jar"

mkdir -p "\$runtime_dir"
if [[ ! -f "\$runtime_jar" ]]; then
  cp "\$store_jar" "\$runtime_jar"
  chmod u+w "\$runtime_jar"
fi

exec ${jre}/bin/java -Dfile.encoding=UTF-8 -jar "\$runtime_jar" "\$@"
EOF
    chmod +x "$out/bin/tlauncher"

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
