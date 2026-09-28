#!/usr/bin/env bash

scale="${1:?missing Hyprland scale}"
projector_x="${2:?missing projector X position}"

hdmi_connected() {
  local status_file

  for status_file in /sys/class/drm/card*-HDMI-A-1/status; do
    if [[ -r "$status_file" ]] && [[ "$(cat "$status_file")" == connected ]]; then
      return 0
    fi
  done

  return 1
}

move_workspaces_to_laptop() {
  local workspace

  while IFS= read -r workspace; do
    hyprctl dispatch moveworkspacetomonitor "$workspace eDP-1" >/dev/null || true
  done < <(
    hyprctl workspaces -j |
      jq -r '.[] | select(.monitor == "HDMI-A-1" and .name != "projector") | .name'
  )
}

enable_projector() {
  hyprctl keyword monitor "eDP-1,preferred,0x0,$scale" >/dev/null
  hyprctl keyword monitor "HDMI-A-1,1920x1080@60,${projector_x}x0,$scale" >/dev/null
  move_workspaces_to_laptop

  # If awww knows about the hot-plugged output, make the overscan margins black.
  # Otherwise Hyprland's empty-output background is already black.
  awww img --outputs HDMI-A-1 --transition-type none 0x000000 >/dev/null 2>&1 || true
  systemctl --user start hyprland-projector-mirror.service
}

disable_projector() {
  systemctl --user stop hyprland-projector-mirror.service
  hyprctl keyword monitor "eDP-1,preferred,0x0,$scale" >/dev/null || true
}

apply_layout() {
  if hdmi_connected; then
    enable_projector
  else
    disable_projector
  fi
}

apply_layout

while true; do
  event_socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

  if [[ ! -S "$event_socket" ]]; then
    sleep 1
    continue
  fi

  socat -u "UNIX-CONNECT:$event_socket" - 2>/dev/null |
    while IFS= read -r event; do
      case "$event" in
        monitoradded*HDMI-A-1* | monitorremoved*HDMI-A-1*)
          sleep 0.5
          apply_layout
          ;;
      esac
    done || true

  sleep 1
  apply_layout
done
