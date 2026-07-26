{ pkgs, ... }:

let
  usbAutomount = pkgs.writeShellApplication {
    name = "usb-automount";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
      mount
      util-linux
    ];
    text = ''
      set -euo pipefail

      action="''${1:-}"
      instance="''${2:-}"
      device="/dev/$instance"
      state_dir="/run/usb-automount"
      state_file="$state_dir/$instance.mountpoint"

      notify_user() {
        local urgency="$1"
        local title="$2"
        local body="$3"
        local uid runtime_dir

        uid="$(id -u ilya)"
        runtime_dir="/run/user/$uid"

        if [[ -S "$runtime_dir/bus" ]]; then
          runuser -u ilya -- env \
            DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus" \
            XDG_RUNTIME_DIR="$runtime_dir" \
            notify-send \
              --app-name="USB automount" \
              --icon="drive-removable-media" \
              --urgency="$urgency" \
              "$title" \
              "$body" || true
        fi
      }

      unmount_device() {
        local mountpoint

        [[ -r "$state_file" ]] || return 0
        IFS= read -r mountpoint < "$state_file"

        if mountpoint -q -- "$mountpoint"; then
          umount -- "$mountpoint" || umount -l -- "$mountpoint"
        fi

        rmdir -- "$mountpoint" 2>/dev/null || true
        rm -f -- "$state_file"
      }

      mount_failed() {
        local mountpoint="$1"
        local output="$2"

        if mountpoint -q -- "$mountpoint"; then
          umount -- "$mountpoint" || umount -l -- "$mountpoint" || true
        fi

        rmdir -- "$mountpoint" 2>/dev/null || true
        rm -f -- "$state_file"
        notify_user critical \
          "USB mount failed" \
          "$device: ''${output:0:300}"
        printf '%s\n' "$output" >&2
        exit 1
      }

      case "$action" in
        mount)
          mkdir -p "$state_dir"

          fs_type="$(blkid -s TYPE -o value "$device" 2>/dev/null || true)"
          label="$(blkid -s LABEL -o value "$device" 2>/dev/null || true)"

          if [[ -z "$fs_type" ]]; then
            notify_user critical \
              "USB mount failed" \
              "$device has no recognized filesystem"
            exit 1
          fi

          name="''${label:-$instance}"
          name="''${name//\//_}"
          name="''${name//$'\n'/_}"
          if [[ -z "$name" || "$name" == "." || "$name" == ".." ]]; then
            name="$instance"
          fi

          mountpoint="/mnt/$name"
          if ! mkdir -- "$mountpoint" 2>/dev/null; then
            mountpoint="/mnt/$name-$instance"
            if ! mkdir -- "$mountpoint" 2>/dev/null; then
              notify_user critical \
                "USB mount failed" \
                "Cannot create $mountpoint for $device"
              exit 1
            fi
          fi

          printf '%s\n' "$mountpoint" > "$state_file"
          uid="$(id -u ilya)"
          gid="$(id -g ilya)"
          mount_type="$fs_type"

          case "$fs_type" in
            ntfs)
              mount_type="ntfs3"
              options="nosuid,nodev,noexec,uid=$uid,gid=$gid,fmask=0133,dmask=0022"
              ;;
            vfat|exfat|ntfs3)
              options="nosuid,nodev,noexec,uid=$uid,gid=$gid,fmask=0133,dmask=0022"
              ;;
            *)
              options="nosuid,nodev,noexec"
              ;;
          esac

          existing_mount="$(findmnt -rn -S "$device" -o TARGET | head -n 1 || true)"
          if [[ -n "$existing_mount" ]]; then
            if ! output="$(mount --bind "$existing_mount" "$mountpoint" 2>&1)"; then
              mount_failed "$mountpoint" "$output"
            fi
            if ! output="$(
              mount -o remount,bind,nosuid,nodev,noexec "$mountpoint" 2>&1
            )"; then
              mount_failed "$mountpoint" "$output"
            fi
          elif ! output="$(mount -t "$mount_type" -o "$options" "$device" "$mountpoint" 2>&1)"; then
            mount_failed "$mountpoint" "$output"
          fi

          notify_user normal \
            "USB drive mounted" \
            "$device is available at $mountpoint"
          ;;
        unmount)
          unmount_device
          ;;
        *)
          printf 'Usage: usb-automount {mount|unmount} DEVICE\n' >&2
          exit 2
          ;;
      esac
    '';
  };
in

{
  services.udisks2.enable = true;
  systemd.tmpfiles.rules = [ "d /mnt 0755 root root -" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_BUS}=="usb", ENV{ID_FS_USAGE}=="filesystem", TAG+="systemd", ENV{SYSTEMD_WANTS}+="usb-automount@%k.service"
  '';

  systemd.services."usb-automount@" = {
    description = "Mount USB filesystem /dev/%I under /mnt";
    bindsTo = [ "dev-%i.device" ];
    after = [ "dev-%i.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${usbAutomount}/bin/usb-automount mount %I";
      ExecStop = "${usbAutomount}/bin/usb-automount unmount %I";
      TimeoutStartSec = "30s";
      TimeoutStopSec = "15s";
    };
  };
}
