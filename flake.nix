{
  description = "NixOS + Hyprland configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self;
        };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          ({ pkgs, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupCommand = pkgs.writeShellScript "home-manager-timestamped-backup" ''
              set -euo pipefail

              target="$1"
              timestamp="$(${pkgs.coreutils}/bin/date -u +%Y%m%dT%H%M%SZ)"
              backup="$target.hm-backup.$timestamp"
              counter=0

              while [ -e "$backup" ]; do
                counter=$((counter + 1))
                backup="$target.hm-backup.$timestamp.$counter"
              done

              ${pkgs.coreutils}/bin/mv -- "$target" "$backup"
            '';
            home-manager.users.ilya = import ./home/ilya/home.nix;
          })
        ];
      };
    };
}
