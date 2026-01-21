#!/usr/bin/env bash
set -euo pipefail

# Quick install script for nix-dotfiles on Ubuntu
# Usage: 
#   curl -fsSL https://raw.githubusercontent.com/atyrode/nix-dotfiles/main/install.sh | bash
#   OR: bash <(curl -fsSL https://raw.githubusercontent.com/atyrode/nix-dotfiles/main/install.sh)

DOTFILES_DIR="${HOME}/nix-dotfiles"
REPO_URL="https://github.com/atyrode/nix-dotfiles.git"

echo "🚀 Installing nix-dotfiles..."

# Install Nix if not present
if ! command -v nix >/dev/null 2>&1; then
    echo "📦 Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    
    # Source nix for current session (try multiple possible locations)
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
    
    # Verify nix is now available
    if ! command -v nix >/dev/null 2>&1; then
        echo "❌ Nix installation may require a shell restart. Please run:"
        echo "   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        echo "   Then re-run this script."
        exit 1
    fi
fi

# Enable flakes
echo "⚙️  Configuring Nix flakes..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Clone or update dotfiles
if [[ -d "$DOTFILES_DIR" ]]; then
    echo "📂 Updating existing dotfiles..."
    cd "$DOTFILES_DIR"
    git pull || echo "⚠️  Could not pull updates (may have local changes)"
else
    echo "📂 Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# Add all files to git (required for flakes)
echo "📝 Staging files for Nix..."
git add -A || echo "⚠️  Some files may not be tracked (this is OK if repo is clean)"

# Build and activate
echo "🔨 Building and activating configuration..."
echo "   (This may take a few minutes on first run...)"

if nix run home-manager -- switch --flake ".#alex" 2>&1; then
    echo ""
    echo "✅ Installation complete!"
    echo ""
    
    # Source Home Manager environment to make zsh available in current session
    if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
        echo "🔄 Loading Home Manager environment..."
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
    
    # Try to find zsh in Home Manager profile
    HM_ZSH=""
    if [[ -f "$HOME/.nix-profile/bin/zsh" ]]; then
        HM_ZSH="$HOME/.nix-profile/bin/zsh"
    elif command -v zsh >/dev/null 2>&1; then
        HM_ZSH="$(command -v zsh)"
    fi
    
    if [[ -n "$HM_ZSH" ]]; then
        echo ""
        echo "📋 Next steps:"
        echo "   1. Switch to zsh now: exec $HM_ZSH"
        echo "   2. Or open a new terminal (zsh will be your default shell)"
        echo "   3. Run 'atyrode' to see all available tools"
        echo ""
        echo "💡 Quick switch: exec $HM_ZSH"
    else
        echo ""
        echo "📋 Next steps:"
        echo "   1. Open a NEW terminal (current session needs to reload)"
        echo "   2. zsh will be your default shell in new terminals"
        echo "   3. Run 'atyrode' to see all available tools"
        echo ""
        echo "⚠️  Note: The current shell session needs to be restarted."
        echo "   Run: source ~/.nix-profile/etc/profile.d/hm-session-vars.sh"
        echo "   Then: exec ~/.nix-profile/bin/zsh"
    fi
else
    echo ""
    echo "❌ Installation failed. Common fixes:"
    echo "   - Ensure all files are tracked: git add -A && git commit -m 'Add files'"
    echo "   - Check error messages above"
    echo "   - Try: nix run home-manager -- switch --flake .#alex"
    exit 1
fi
