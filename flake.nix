{
  description = "atyrode dotfiles (linux / WSL first)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    # Default system (can be overridden)
    defaultSystem = "x86_64-linux"; # WSL Ubuntu (almost always this)
    defaultUsername = "alex";
    
    # Helper function to create home configuration
    mkHomeConfig = { system ? defaultSystem, username ? defaultUsername }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };

        modules = [
          ./home
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
          }
        ];
      };
  in {
    # Default configuration
    homeConfigurations.${defaultUsername} = mkHomeConfig { };
    
    # Allow building for different systems/users
    # Example: nix build .#homeConfigurations.alex
    # Or override: nix build .#homeConfigurations.alex --override-input nixpkgs github:NixOS/nixpkgs/nixos-24.05
  };
}
