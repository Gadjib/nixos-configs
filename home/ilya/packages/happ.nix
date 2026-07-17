{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  coreutils,
  diffutils,
  makeWrapper,
  zstd,
  alsa-lib,
  e2fsprogs,
  fontconfig,
  freetype,
  gawk,
  iproute2,
  jq,
  libglvnd,
  libgpg-error,
  libX11,
  libxcb,
  openssl,
  qt6,
  writeShellScript,
  zlib,
}:

let
  fixSingboxConfig = writeShellScript "happ-fix-singbox-config" ''
    set -euo pipefail

    config="''${XDG_CONFIG_HOME:-$HOME/.config}/Happ/config.json"
    [[ -f "$config" ]] || exit 0

    iface="$(${iproute2}/bin/ip -4 route show default 0.0.0.0/0 \
      | ${gawk}/bin/awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }')"
    [[ -n "$iface" ]] || exit 0

    tmp="$(${coreutils}/bin/mktemp "''${config}.tmp.XXXXXX")"
    if ! ${jq}/bin/jq --arg iface "$iface" '
      if (.outbounds | type) == "array" then
        .outbounds |= map(
          if .type == "direct" or .tag == "direct" then
            . + { bind_interface: $iface }
          else
            .
          end
        )
      else
        .
      end
    ' "$config" > "$tmp"; then
      ${coreutils}/bin/rm -f "$tmp"
      exit 0
    fi

    if ! ${diffutils}/bin/cmp -s "$tmp" "$config"; then
      if [[ ! -e "''${config}.backup-before-nixos-bind-interface" ]]; then
        ${coreutils}/bin/cp "$config" "''${config}.backup-before-nixos-bind-interface"
      fi
      ${coreutils}/bin/mv "$tmp" "$config"
    else
      ${coreutils}/bin/rm -f "$tmp"
    fi
  '';
in
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

    install -Dm755 ${fixSingboxConfig} "$out/bin/happ-fix-singbox-config"

    makeWrapper "$out/share/happ/bin/Happ" "$out/bin/happ" \
      --run "$out/bin/happ-fix-singbox-config" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ openssl ]}" \
      --unset QT_QPA_PLATFORMTHEME \
      --unset QT_STYLE_OVERRIDE \
      --unset QT_PLUGIN_PATH \
      --unset QML2_IMPORT_PATH \
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
