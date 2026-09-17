set -euo pipefail

state_root="$HOME/.local/state/nixos-desktop-isolation"
session_state="$state_root/session-v2"
legacy_state="$state_root/active-hyprland"
initialized="$state_root/plasma-reset-v1"
lock_file="${XDG_RUNTIME_DIR:?}/nixos-desktop-isolation.lock"

hypr_root="$HOME/.config/.desktop-profiles/hyprland"
managed_ids=(
  kdeglobals
  kded5rc
  gtk3-settings
  gtk4-settings
  gtk4-css
  gtk4-dark-css
  gtk4-assets
  firefox-userchrome
)
managed_paths=(
  .config/kdeglobals
  .config/kded5rc
  .config/gtk-3.0/settings.ini
  .config/gtk-4.0/settings.ini
  .config/gtk-4.0/gtk.css
  .config/gtk-4.0/gtk-dark.css
  .config/gtk-4.0/assets
  .mozilla/firefox/hyprland/chrome/userChrome.css
)
managed_sources=(
  "$HOME/.config/.home-manager-kdeglobals"
  "$HOME/.config/.home-manager-kded5rc"
  "$hypr_root/gtk-3.0/settings.ini"
  "$hypr_root/gtk-4.0/settings.ini"
  "$hypr_root/gtk-4.0/gtk.css"
  "$hypr_root/gtk-4.0/gtk-dark.css"
  "$hypr_root/gtk-4.0/assets"
  "$hypr_root/firefox/userChrome.css"
)

plasma_reset_paths=(
  .config/bluedevilglobalrc
  .config/breezerc
  .config/gtk-3.0/settings.ini
  .config/gtk-4.0/assets
  .config/gtk-4.0/gtk-dark.css
  .config/gtk-4.0/gtk.css
  .config/gtk-4.0/settings.ini
  .config/gtkrc
  .config/gtkrc-2.0
  .config/kcminputrc
  .config/kded5rc
  .config/kded6rc
  .config/kdeglobals
  .config/kglobalshortcutsrc
  .config/krunnerrc
  .config/kscreenlockerrc
  .config/ksmserverrc
  .config/kwinrc
  .config/kxkbrc
  .config/mimeapps.list
  .config/plasma-localerc
  .config/plasma-org.kde.plasma.desktop-appletsrc
  .config/plasmaparc
  .config/plasmashellrc
  .config/powermanagementprofilesrc
  .config/xsettingsd/xsettingsd.conf
  .local/share/applications/mimeapps.list
  .local/share/kscreen
)

# Publish markers by rename; sync before any destructive operation so the
# recovery snapshot and its phase reach disk before the live files change.
set_phase() {
  printf '%s\n' "$2" > "$1/phase.next"
  mv -T -- "$1/phase.next" "$1/phase"
  sync -f "$state_root"
}

archive_state() {
  local source="$1" label="$2" archive
  mkdir -p "$state_root/backups"
  archive="$(mktemp -d "$state_root/backups/$label.XXXXXXXX")"
  mv -T -- "$source" "$archive/snapshot"
  sync -f "$state_root"
}

initialize_plasma_defaults() {
  local transaction="$state_root/initial-reset-v2" pending relative source target

  [[ ! -e "$initialized" ]] || return 0
  if [[ ! -d "$transaction" ]]; then
    pending="$transaction.pending"
    remove_writable_tree "$pending"
    mkdir -p "$pending/files"
    set_phase "$pending" saving
    for relative in "${plasma_reset_paths[@]}"; do
      source="$HOME/$relative"
      if [[ -e "$source" || -L "$source" ]]; then
        target="$pending/files/$relative"
        mkdir -p "$(dirname "$target")"
        cp -a -- "$source" "$target"
      fi
    done
    dconf dump /org/gnome/desktop/interface/ > "$pending/dconf-interface.ini"
    set_phase "$pending" resetting
    mv -T -- "$pending" "$transaction"
    sync -f "$state_root"
  fi

  # The complete original snapshot remains here even after a successful reset.
  for relative in "${plasma_reset_paths[@]}"; do
    remove_writable_tree "$HOME/$relative"
  done
  dconf reset -f /org/gnome/desktop/interface/
  sync -f "$state_root"
  printf '%s\n' "$transaction" > "$initialized.next"
  mv -T -- "$initialized.next" "$initialized"
  sync -f "$state_root"
}

copy_hypr_source() {
  local source="$1"
  local target="$2"

  [[ -e "$source" || -L "$source" ]] || {
    printf 'desktop-session-profile: missing Hyprland source: %s\n' "$source" >&2
    return 1
  }

  mkdir -p "$(dirname "$target")"
  if [[ -d "$source" ]]; then
    cp -aL -- "$source" "$target"
    chmod -R u+rwX -- "$target"
  else
    install -m 0600 -- "$source" "$target"
  fi
}

remove_writable_tree() {
  local target="$1"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ ! -L "$target" ]]; then
      chmod -R u+w -- "$target" 2>/dev/null || true
    fi
    rm -rf -- "$target"
  fi
}

apply_hyprland_defaults() {
  local index target

  for index in "${!managed_ids[@]}"; do
    target="$HOME/${managed_paths[$index]}"
    remove_writable_tree "$target"
    copy_hypr_source "${managed_sources[$index]}" "$target"
  done

  dconf reset -f /org/gnome/desktop/interface/
  dconf load /org/gnome/desktop/interface/ < "$hypr_root/dconf-interface.ini"
}

validate_snapshot() {
  local id
  [[ -f "$session_state/dconf-interface.ini" ]] || {
    printf 'desktop-session-profile: missing dconf snapshot; refusing to change live settings\n' >&2
    return 1
  }
  for id in "${managed_ids[@]}"; do
    [[ -e "$session_state/files/$id" || -L "$session_state/files/$id" ||
       -f "$session_state/files/$id.absent" ]] || {
      printf 'desktop-session-profile: incomplete snapshot for %s\n' "$id" >&2
      return 1
    }
  done
}

save_plasma() {
  local pending="$session_state.pending" index id target source

  # A pending snapshot has never been used to modify the live files.
  remove_writable_tree "$pending"
  mkdir -p "$pending/files"
  set_phase "$pending" saving
  if [[ -d "$legacy_state" ]]; then
    # Preserve the old format verbatim before interpreting an interrupted v1
    # save/restore. Missing entries may already have been restored to HOME.
    cp -a -- "$legacy_state" "$pending/legacy-original"
  fi
  for index in "${!managed_ids[@]}"; do
    id="${managed_ids[$index]}"
    target="$HOME/${managed_paths[$index]}"
    source="$target"
    if [[ -e "$legacy_state/files/$id" || -L "$legacy_state/files/$id" ]]; then
      source="$legacy_state/files/$id"
    elif [[ -f "$legacy_state/files/$id.absent" || "$id" == firefox-userchrome ]]; then
      if [[ "$id" == firefox-userchrome && ( -e "$target" || -L "$target" ) ]]; then
        cp -a -- "$target" "$pending/firefox-userchrome-before-switch"
      fi
      touch "$pending/files/$id.absent"
      continue
    fi
    if [[ -e "$source" || -L "$source" ]]; then
      cp -a -- "$source" "$pending/files/$id"
    else
      touch "$pending/files/$id.absent"
    fi
  done
  if [[ -f "$legacy_state/dconf-interface.ini" ]]; then
    cp -a -- "$legacy_state/dconf-interface.ini" "$pending/dconf-interface.ini"
  elif [[ -e "$legacy_state/.active" ]]; then
    printf 'desktop-session-profile: legacy active state has no dconf backup; refusing migration\n' >&2
    return 1
  else
    dconf dump /org/gnome/desktop/interface/ > "$pending/dconf-interface.ini"
  fi
  set_phase "$pending" saved
  mv -T -- "$pending" "$session_state"
  sync -f "$state_root"
}

prepare_session() {
  local phase
  initialize_plasma_defaults
  if [[ -d "$session_state" ]]; then
    phase="$(cat "$session_state/phase")"
    case "$phase" in
      restored) archive_state "$session_state" completed ;;
      saved|applying|active|restoring) validate_snapshot ;;
      *) printf 'desktop-session-profile: unknown phase: %s\n' "$phase" >&2; return 1 ;;
    esac
  fi
  if [[ -d "$legacy_state" ]]; then
    if [[ ! -d "$session_state" ]]; then
      save_plasma
    fi
    validate_snapshot
    # Retire v1 only after the v2 snapshot has been committed and synced.
    archive_state "$legacy_state" legacy-v1
  fi
}

restore_plasma() {
  local index id target saved
  validate_snapshot
  set_phase "$session_state" restoring
  for index in "${!managed_ids[@]}"; do
    id="${managed_ids[$index]}"
    target="$HOME/${managed_paths[$index]}"
    saved="$session_state/files/$id"
    remove_writable_tree "$target"
    if [[ -e "$saved" || -L "$saved" ]]; then
      mkdir -p "$(dirname "$target")"
      cp -a -- "$saved" "$target"
    fi
  done
  dconf reset -f /org/gnome/desktop/interface/
  dconf load /org/gnome/desktop/interface/ < "$session_state/dconf-interface.ini"
  sync -f "$state_root"
  set_phase "$session_state" restored
  archive_state "$session_state" completed
}

activate_hyprland() {
  prepare_session
  if [[ -d "$session_state" && "$(cat "$session_state/phase")" == restoring ]]; then
    restore_plasma
  fi
  if [[ ! -d "$session_state" ]]; then
    save_plasma
  fi
  validate_snapshot
  # Check every source before replacing even the first live setting.
  local source
  for source in "${managed_sources[@]}" "$hypr_root/dconf-interface.ini"; do
    [[ -e "$source" ]] || {
      printf 'desktop-session-profile: missing Hyprland source: %s\n' "$source" >&2
      return 1
    }
  done
  set_phase "$session_state" applying
  apply_hyprland_defaults
  set_phase "$session_state" active
}

deactivate_hyprland() {
  prepare_session
  if [[ -d "$session_state" ]]; then
    restore_plasma
  fi

  systemctl --user unset-environment \
    ADW_DEBUG_COLOR_SCHEME \
    BROWSER \
    GTK_THEME \
    HYPRCURSOR_SIZE \
    HYPRCURSOR_THEME \
    KDE_SESSION_VERSION \
    QT_QPA_PLATFORMTHEME \
    QT_QUICK_CONTROLS_STYLE \
    XCURSOR_SIZE \
    XCURSOR_THEME \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_DESKTOP \
    XDG_MENU_PREFIX || true
}

mkdir -p "$(dirname "$lock_file")"
exec 9> "$lock_file"
flock 9

case "${1:-}" in
  hyprland)
    activate_hyprland
    ;;
  plasma)
    deactivate_hyprland
    ;;
  *)
    printf 'Usage: desktop-session-profile {hyprland|plasma}\n' >&2
    exit 2
    ;;
esac
