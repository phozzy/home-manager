{
  description = "Home Manager configuration of deck";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixneovim.url = "github:nixneovim/nixneovim";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixneovim,
    nixpkgs,
    home-manager,
    ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nixneovim.overlays.default
        ];
      };
    in {
      homeConfigurations."deck" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          nixneovim.nixosModules.default
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
