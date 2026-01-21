{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
  ];

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
