{
  lib,
  symlinkJoin,
  makeWrapper,
  telegram-desktop,
}:

symlinkJoin {
  name = "telegram-desktop-portal-${telegram-desktop.version}";
  paths = [ telegram-desktop ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    rm -f "$out/bin/Telegram"
    makeWrapper "${telegram-desktop}/bin/Telegram" "$out/bin/Telegram" \
      --set QT_QPA_PLATFORMTHEME xdgdesktopportal

    service="$out/share/dbus-1/services/org.telegram.desktop.service"
    if [ -f "$service" ]; then
      rm -f "$service"
      install -Dm0644 \
        "${telegram-desktop}/share/dbus-1/services/org.telegram.desktop.service" \
        "$service"
      substituteInPlace "$service" \
        --replace-fail \
        "Exec=${telegram-desktop}/bin/Telegram" \
        "Exec=$out/bin/Telegram"
    fi
  '';

  meta = telegram-desktop.meta // {
    description = "${telegram-desktop.meta.description} with XDG portal file dialogs";
    mainProgram = "Telegram";
    platforms = lib.platforms.linux;
  };
}
