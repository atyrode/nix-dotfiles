{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # File navigation & search
    zoxide
    fzf
    fd
    bat
    tree
    
    # System monitoring
    btop
    dua
    neofetch

    # Python tooling
    python3
    uv

    # JavaScript/TypeScript tooling
    nodejs_20
    bun

    # Container tools
    docker
    docker-compose
    dive

    # Development tools
    git
    tmux
    rustup
  ];
}
