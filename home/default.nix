{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
