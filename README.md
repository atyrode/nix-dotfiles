# nix-dotfiles

Nix + Home Manager configuration for my shell and developer tooling (WSL/Linux first).

## Requirements

- Nix installed with flakes enabled

Enable flakes:
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/atyrode/nix-dotfiles.git ~/nix-dotfiles
cd ~/nix-dotfiles
```

2. Build and activate the configuration:
```bash
nix run home-manager -- switch --flake .#alex
```

Or use the `zconf` function (after initial setup):
```bash
zconf
```

## Updating

To update your dotfiles:
```bash
cd ~/nix-dotfiles
git pull
zconf
```

To update Nix packages:
```bash
nix flake update
zconf
```

## Structure

- `flake.nix` - Main flake configuration
- `home/` - Home Manager modules
  - `default.nix` - Main home configuration
  - `packages.nix` - Package definitions
  - `zsh.nix` - Zsh configuration
  - `git.nix` - Git configuration
  - `shell/functions.zsh` - Custom shell functions

## Features

- **Shell**: Zsh with oh-my-zsh, zoxide, fzf
- **Python**: Python 3, uv for package management
- **JavaScript**: Node.js 20, Bun
- **Containers**: Docker, docker-compose, dive
- **Development**: Git, tmux, rustup
- **Utilities**: bat, btop, tree, dua, neofetch

## Custom Functions

See `home/shell/functions.zsh` for custom shell functions including:
- `venv` - Python virtual environment management
- `zconf` - Quick Home Manager switch
- `hub` - Clone and setup GitHub repos
- And more...