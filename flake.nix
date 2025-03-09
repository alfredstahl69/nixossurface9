{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, ... }:
  let
    system = "x86_64-linux";  # Define system architecture once
  in {
    # Define nixpkgs settings (Allow Unfree Packages)
    nixpkgsConfig = {
      allowUnfree = true;
    };

    # NixOS Configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.microsoft-surface-pro-9
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.phil = import ./home.nix;
        }
      ];
    };

    # Home Manager Configuration (Fixes home-manager switch --flake)
    homeConfigurations.phil = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./home.nix ];
    };
  };
}
