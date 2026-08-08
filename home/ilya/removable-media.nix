{ pkgs, ... }:

let
  mntLink = pkgs.writeShellApplication {
    name = "udiskie-mnt-link";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      jq
      util-linux
    ];
    text = ''
      set -euo pipefail

      state_dir="''${XDG_RUNTIME_DIR:?}/udiskie-mnt-links"

      device_name() {
        local device="$1"
        local name="''${device##*/}"

        [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || return 1
        printf '%s\n' "$name"
      }

      remove_link() {
        local device="$1"
        local name state_file link target current_target

        name="$(device_name "$device")" || return 0
        state_file="$state_dir/$name"
        [[ -r "$state_file" ]] || return 0

        link="$(sed -n '1p' "$state_file")"
        target="$(sed -n '2p' "$state_file")"

        case "$link" in
          /mnt/*) ;;
          *) return 0 ;;
        esac

        if [[ -L "$link" ]]; then
          current_target="$(readlink -- "$link")"
          if [[ "$current_target" == "$target" ]]; then
            rm -f -- "$link"
          fi
        fi
        rm -f -- "$state_file"
      }

      add_link() {
        local device="$1"
        local mount_path="$2"
        local name base link state_file

        case "$mount_path" in
          /run/media/ilya/*|/media/ilya/*) ;;
          *) return 0 ;;
        esac
        [[ -d "$mount_path" ]] || return 0

        name="$(device_name "$device")" || return 0
        base="''${mount_path##*/}"
        [[ -n "$base" && "$base" != "." && "$base" != ".." ]] || base="$name"

        mkdir -p "$state_dir"
        chmod 0700 "$state_dir"
        state_file="$state_dir/$name"
        remove_link "$device"

        link="/mnt/$base"
        if [[ -e "$link" || -L "$link" ]]; then
          link="/mnt/$base-$name"
        fi
        if [[ -e "$link" || -L "$link" ]]; then
          return 0
        fi

        ln -s -- "$mount_path" "$link"
        printf '%s\n%s\n' "$link" "$mount_path" > "$state_file"
      }

      sync_links() {
        local source target

        mkdir -p "$state_dir"
        chmod 0700 "$state_dir"
        while IFS=$'\t' read -r source target; do
          case "$source" in
            /dev/*) add_link "$source" "$target" ;;
          esac
        done < <(
          findmnt --json --list -o SOURCE,TARGET |
            jq -r '
              .filesystems[]
              | select(.target | test("^/(run/)?media/ilya/"))
              | [.source, .target]
              | @tsv
            '
        )
      }

      cleanup_links() {
        local state_file

        [[ -d "$state_dir" ]] || return 0
        for state_file in "$state_dir"/*; do
          [[ -f "$state_file" ]] || continue
          remove_link "/dev/''${state_file##*/}"
        done
        rmdir "$state_dir" 2>/dev/null || true
      }

      case "''${1:-}" in
        event)
          event="''${2:-}"
          device="''${3:-}"
          mount_path="''${4:-}"
          case "$event" in
            device_mounted) add_link "$device" "$mount_path" ;;
            device_unmounted|device_removed) remove_link "$device" ;;
          esac
          ;;
        sync)
          sync_links
          ;;
        cleanup)
          cleanup_links
          ;;
        *)
          printf 'Usage: udiskie-mnt-link {event EVENT DEVICE MOUNT_PATH|sync|cleanup}\n' >&2
          exit 2
          ;;
      esac
    '';
  };
in

{
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    settings = {
      program_options.event_hook = [
        "${mntLink}/bin/udiskie-mnt-link"
        "event"
        "{event}"
        "{device_file}"
        "{mount_path}"
      ];
      device_config = [
        {
          id_usage = "filesystem";
          options = [
            "nosuid"
            "nodev"
            "noexec"
          ];
        }
      ];
    };
  };

  systemd.user.services.udiskie.Service = {
    ExecStartPost = "${mntLink}/bin/udiskie-mnt-link sync";
    ExecStopPost = "${mntLink}/bin/udiskie-mnt-link cleanup";
    Restart = "on-failure";
    RestartSec = 1;
  };
}
