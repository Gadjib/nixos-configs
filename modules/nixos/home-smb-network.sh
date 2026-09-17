# This only reads NetworkManager's cached AP list. Never probe the NAS here.
export LC_ALL=C
if ! networks="$(nmcli --wait 2 --terse --escape no --fields ACTIVE,SSID device wifi list --rescan no)"; then
  exit 1
fi
while IFS= read -r network; do
  case "$network" in
    yes:0xDEADBEEF*) exit 0 ;;
  esac
done <<< "$networks"
exit 1
