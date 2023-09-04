{
  description = "Home Manager configuration of deck";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixvim.url = "github:nix-community/nixvim";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixvim,
    nixpkgs,
    home-manager,
    ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
        ];
      };
      userName = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
    in {
      homeConfigurations."${userName}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          nixvim.homeManagerModules.nixvim
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
