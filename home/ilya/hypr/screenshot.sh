# One screenshot workflow at a time, including the editor. Keep the lock file:
# unlinking it would let concurrent callers lock different inodes.
set -euo pipefail

area=${1:?expected area or screen}
destination=${2:?expected clipboard or editor}
case "$area:$destination" in
  area:clipboard|screen:clipboard|area:editor|screen:editor) ;;
  *) exit 2 ;;
esac

exec 9>"${XDG_RUNTIME_DIR:?}/hyprland-screenshot.lock"
flock --nonblock 9 || exit 0

geometry=()
if [[ "$area" == area ]]; then
  selection=$(slurp) || exit 0
  [[ -n "$selection" ]] || exit 0
  geometry=(-g "$selection")
fi

capture=$(mktemp "${XDG_RUNTIME_DIR}/hyprland-screenshot.XXXXXX.png")
trap 'rm -f -- "$capture"' EXIT
# Complete capture before touching the clipboard or opening the editor.
grim "${geometry[@]}" "$capture"

# Do not pass the lock descriptor to clipboard/background child processes.
case "$destination" in
  clipboard) wl-copy --type image/png < "$capture" 9>&- ;;
  editor) swappy -f "$capture" 9>&- ;;
esac
