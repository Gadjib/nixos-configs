{ pkgs, ... }:

let
  incy = pkgs.callPackage ../../home/ilya/packages/incy.nix { };
in
{
  environment.systemPackages = [
    incy
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id == "cc.incy.vpn.run-helper" &&
        subject.user == "ilya" &&
        subject.active
      ) {
        return polkit.Result.YES;
      }
    });
  '';
}
