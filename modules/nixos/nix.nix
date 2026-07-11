{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  programs.nh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    home-manager
    nh
    nix-output-monitor
    nix-tree
    nix-diff
    nvd
  ];
}
