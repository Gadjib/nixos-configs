{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.ilya = {
    isNormalUser = true;
    description = "ilya";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };
}
