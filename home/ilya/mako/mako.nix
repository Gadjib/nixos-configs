{ pkgs, ... }:

let
  appearance = import ../appearance.nix { inherit pkgs; };
in

{
  services.mako = {
    enable = true;
    settings = {
      font = "${appearance.fonts.general.name} ${toString appearance.fonts.general.size}";
      background-color = "#24273acc";
      text-color = "#cad3f5ff";
      border-color = "#8aadf4ff";
      progress-color = "over #8aadf4ff";
      border-size = 2;
      border-radius = 8;
      padding = "10";
      margin = "8";
      default-timeout = 5000;
    };
  };
}
