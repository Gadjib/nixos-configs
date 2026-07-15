{ pkgs, ... }:

let
  incy = pkgs.callPackage ../../home/ilya/packages/incy.nix { };
in
{
  environment.systemPackages = [
    incy
  ];
}
