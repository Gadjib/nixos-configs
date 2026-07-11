{
  home.file.".local/bin/wifi-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      notify() {
        if command -v notify-send >/dev/null 2>&1; then
          notify-send "Wi-Fi" "$1"
        fi
      }

      rofi_menu() {
        rofi -dmenu -i -matching fuzzy -no-custom -p "$1"
      }

      wifi_device() {
        nmcli -t --escape no -f DEVICE,TYPE,STATE device status \
          | awk -F: '$2 == "wifi" { print $1; exit }'
      }

      wifi_state="$(nmcli -t --escape no -f WIFI general 2>/dev/null | head -n1 || true)"
      device="$(wifi_device || true)"
      active_connection="$(nmcli -t --escape no -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2 == "802-11-wireless" { print $1; exit }')"

      menu_items=()
      if [[ "$wifi_state" == "enabled" ]]; then
        if [[ -n "$active_connection" ]]; then
          menu_items+=("󰤨 Connected: $active_connection")
        fi
        menu_items+=("󰖪 Disable Wi-Fi")
        menu_items+=("󰑓 Rescan")
        if [[ -n "$active_connection" ]]; then
          menu_items+=("󰅖 Disconnect")
        fi
      else
        menu_items+=("󰖩 Enable Wi-Fi")
      fi

      networks_file="$(mktemp)"
      trap 'rm -f "$networks_file"' EXIT

      if [[ "$wifi_state" == "enabled" ]]; then
        index=0
        while IFS=: read -r in_use ssid signal security; do
          [[ -z "$ssid" ]] && continue
          index=$((index + 1))

          lock_icon=""
          [[ -n "$security" ]] && lock_icon=""

          active_icon=" "
          [[ "$in_use" == "*" ]] && active_icon="●"

          printf '%s\t%s\t%s\n' "$index" "$ssid" "$security" >> "$networks_file"
          menu_items+=("''${index}  ''${active_icon}  ''${signal}%  ''${lock_icon}  ''${ssid}")
        done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no 2>/dev/null)
      fi

      choice="$(printf '%s\n' "''${menu_items[@]}" | rofi_menu "Wi-Fi")"
      [[ -z "$choice" ]] && exit 0

      case "$choice" in
        "󰤨 Connected:"*)
          exit 0
          ;;
        "󰖩 Enable Wi-Fi")
          nmcli radio wifi on
          notify "Enabled"
          ;;
        "󰖪 Disable Wi-Fi")
          nmcli radio wifi off
          notify "Disabled"
          ;;
        "󰑓 Rescan")
          nmcli device wifi rescan
          notify "Scan requested"
          ;;
        "󰅖 Disconnect")
          [[ -n "$device" ]] || exit 1
          nmcli device disconnect "$device"
          notify "Disconnected"
          ;;
        *)
          selected_index="$(awk '{ print $1 }' <<< "$choice")"
          [[ "$selected_index" =~ ^[0-9]+$ ]] || exit 0

          row="$(awk -F $'\t' -v index="$selected_index" '$1 == index { print; exit }' "$networks_file")"
          [[ -n "$row" ]] || exit 0
          IFS=$'\t' read -r _ ssid security <<< "$row"

          if nmcli connection show "$ssid" >/dev/null 2>&1; then
            if nmcli connection up "$ssid"; then
              notify "Connected to $ssid"
              exit 0
            fi
          fi

          if [[ -n "$security" ]]; then
            password="$(rofi -dmenu -password -p "Password for $ssid")"
            [[ -z "$password" ]] && exit 0
            nmcli device wifi connect "$ssid" password "$password"
          else
            nmcli device wifi connect "$ssid"
          fi
          notify "Connected to $ssid"
          ;;
      esac
    '';
  };

  home.file.".local/bin/bluetooth-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      rofi_cmd=(rofi -dmenu -i -p "Bluetooth")

      power_state="$(bluetoothctl show 2>/dev/null | awk '/Powered:/ { print $2; exit }')"
      menu_items=()

      if [[ "$power_state" == "yes" ]]; then
        menu_items+=("󰂲 Disable Bluetooth")
        menu_items+=("󰑓 Scan")
      else
        menu_items+=("󰂯 Enable Bluetooth")
      fi

      while read -r mac name; do
        [[ -z "$mac" || -z "$name" ]] && continue
        info="$(bluetoothctl info "$mac" 2>/dev/null || true)"
        connected="$(awk '/Connected:/ { print $2; exit }' <<< "$info")"
        paired="$(awk '/Paired:/ { print $2; exit }' <<< "$info")"

        status="available"
        [[ "$paired" == "yes" ]] && status="paired"
        [[ "$connected" == "yes" ]] && status="connected"

        menu_items+=("$status  $name  $mac")
      done < <(bluetoothctl devices | sed -E 's/^Device ([[:xdigit:]:]+) (.*)$/\1 \2/')

      choice="$(printf '%s\n' "''${menu_items[@]}" | "''${rofi_cmd[@]}")"
      [[ -z "$choice" ]] && exit 0

      case "$choice" in
        "󰂯 Enable Bluetooth")
          bluetoothctl power on
          ;;
        "󰂲 Disable Bluetooth")
          bluetoothctl power off
          ;;
        "󰑓 Scan")
          bluetoothctl power on
          timeout 8 bluetoothctl scan on >/dev/null 2>&1 || true
          ;;
        connected*)
          mac="$(awk '{ print $NF }' <<< "$choice")"
          bluetoothctl disconnect "$mac"
          ;;
        paired*|available*)
          mac="$(awk '{ print $NF }' <<< "$choice")"
          bluetoothctl trust "$mac" >/dev/null 2>&1 || true
          bluetoothctl pair "$mac" >/dev/null 2>&1 || true
          bluetoothctl connect "$mac"
          ;;
      esac
    '';
  };
}
