{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
  makeDesktopItem,
  jre,
}:

let
  desktopItem = makeDesktopItem {
    name = "tlauncher";
    desktopName = "TLauncher";
    genericName = "Minecraft launcher";
    comment = "TLauncher Minecraft launcher";
    exec = "tlauncher";
    icon = "applications-games";
    categories = [
      "Game"
    ];
    startupWMClass = "TLauncher";
  };
in
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
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/tlauncher" "$out/bin" "$out/share/applications"
    unzip -j "$src" TLauncher.jar -d "$out/share/tlauncher"

    makeWrapper ${jre}/bin/java "$out/bin/tlauncher" \
      --add-flags "-jar $out/share/tlauncher/TLauncher.jar"

    cp ${desktopItem}/share/applications/*.desktop "$out/share/applications/"

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
