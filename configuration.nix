# Compatibility entrypoint for non-flake commands.
#
# Preferred workflow:
#   sudo nixos-rebuild test --flake /home/ilya/nixos-config#thinkpad-nix
#   sudo nixos-rebuild switch --flake /home/ilya/nixos-config#thinkpad-nix

{ ... }:

{
  imports = [
    ./hosts/nixos/configuration.nix
  ];
}
