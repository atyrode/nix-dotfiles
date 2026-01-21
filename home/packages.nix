{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zoxide
    fzf
    fd
    bat
    btop
    tree
    dua
    neofetch

    python3
    uv
    nodejs_20
    bun

    docker
    docker-compose
    dive

    git
    tmux
    rustup
  ];
}
