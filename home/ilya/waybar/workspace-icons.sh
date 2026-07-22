#!/usr/bin/env bash
set -euo pipefail

icon_for_class() {
  case "$1" in
    kitty) printf '' ;;
    firefox) printf '' ;;
    TelegramDesktop | org.telegram.desktop) printf '' ;;
    spotify) printf '' ;;
    Happ) printf '󰒍' ;;
    Code | code | code-url-handler) printf '󰨞' ;;
    org.kde.dolphin) printf '' ;;
    Obsidian | obsidian) printf '󰠮' ;;
    Steam | steam | steam_app_*) printf '' ;;
    TLauncher | tlauncher | Minecraft*) printf '' ;;
    org.kde.gwenview) printf '' ;;
    org.kde.okular) printf '' ;;
    org.kde.kate) printf '󰷈' ;;
    pavucontrol) printf '' ;;
    org.kde.plasma-systemmonitor) printf '' ;;
    *) printf '' ;;
  esac
}

sync_workspace_icons() {
  local state rows id current_name class desired

  state="$(hyprctl --batch -j 'clients; workspaces' 2>/dev/null)" || return 0
  rows="$(
    jq -r -s '
      .[0] as $clients
      | .[1][]
      | select(.id > 0)
      | .id as $id
      | [
          $id,
          .name,
          (
            $clients
            | map(select(
                .workspace.id == $id
                and .mapped == true
                and .hidden == false
              ))
            | if length == 0 then
                ""
              else
                max_by(.size[0] * .size[1]).class
              end
          )
        ]
      | @tsv
    ' <<<"$state" 2>/dev/null
  )" || return 0

  while IFS=$'\t' read -r id current_name class; do
    [[ -n "$id" ]] || continue

    desired="$id"
    if [[ -n "$class" ]]; then
      desired="$id $(icon_for_class "$class")"
    fi

    if (( print_only )); then
      printf '%s\t%s\n' "$id" "$desired"
    elif [[ "$current_name" != "$desired" ]]; then
      hyprctl dispatch renameworkspace "$id $desired" >/dev/null
    fi
  done <<<"$rows"
}

print_only=0

if [[ "${1:-}" == "--print" ]]; then
  print_only=1
  sync_workspace_icons
  exit 0
fi

while true; do
  sync_workspace_icons
  sleep 1
done
