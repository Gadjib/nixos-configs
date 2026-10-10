{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  desktop-file-utils,
  wayland,
  libxkbcommon,
  libX11,
  libXcursor,
  libXrandr,
  libXi,
  libxcb,
  libGL,
  vulkan-loader,
  fontconfig,
  freetype,
}:

let
  runtimeLibraries = [
    stdenv.cc.cc.lib
    wayland
    libxkbcommon
    libX11
    libXcursor
    libXrandr
    libXi
    libxcb
    libGL
    vulkan-loader
    fontconfig
    freetype
  ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "artcraft-launcher";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/storytold/craft-launcher/releases/download/v${finalAttrs.version}/artcraft-launcher-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-SlbDgi1JyroQZ+u7M52LeU5yV0I2+Tzr7l/BoyZUbPU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    desktop-file-utils
  ];

  buildInputs = runtimeLibraries;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r bin share "$out/"
    wrapProgram "$out/bin/artcraft-launcher" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}
    desktop-file-validate "$out/share/applications/ai.storyteller.artcraft-launcher.desktop"

    runHook postInstall
  '';

  meta = {
    description = "Launcher for installing and updating the ArtCraft app suite";
    homepage = "https://github.com/storytold/craft-launcher";
    license = with lib.licenses; [ mit asl20 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "artcraft-launcher";
  };
})
