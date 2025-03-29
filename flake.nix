
{
  description = "NixOS configuration with flakes";

  inputs = {
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, minegrub-theme, ... }:
  let
    system = "x86_64-linux";
  in {
    nixpkgsConfig = { allowUnfree = true; };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.microsoft-surface-pro-9
        minegrub-theme.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.phil = import ./home.nix;
        }
      ];
    };

    homeConfigurations.phil = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./home.nix ];
    };
  };
}
