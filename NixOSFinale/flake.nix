### Updated flake.nix
{
  description = "NixOS configuration with flakes";

  inputs = {
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # Added Chaotic-Nyx
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, minegrub-theme, chaotic, ... }:
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
        chaotic.nixosModules.nyx-cache # Added Chaotic-Nyx modules
        chaotic.nixosModules.nyx-overlay
        chaotic.nixosModules.nyx-registry
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
