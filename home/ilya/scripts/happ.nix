{ pkgs, ... }:

let
  happ = pkgs.callPackage ../packages/happ.nix { };
in
{
  systemd.user.services.happ-fix-singbox-config = {
    Unit.Description = "Pin Happ sing-box direct outbound to the current uplink";
    Service = {
      Type = "oneshot";
      ExecStart = "${happ}/bin/happ-fix-singbox-config";
    };
  };

  systemd.user.paths.happ-fix-singbox-config = {
    Unit.Description = "Watch Happ sing-box config for routing-loop fixes";
    Path = {
      PathExists = "%h/.config/Happ/config.json";
      PathChanged = "%h/.config/Happ/config.json";
      Unit = "happ-fix-singbox-config.service";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
