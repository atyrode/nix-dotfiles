# Testing the Install Script

## Quick Test on Fresh WSL Ubuntu

### Step 1: Create new WSL instance (in PowerShell/CMD on Windows)
```powershell
# List available Ubuntu versions
wsl --list --online

# Install Ubuntu (replace with version you want, e.g., Ubuntu-22.04)
wsl --install -d Ubuntu-22.04

# Or if you want to test with a specific name
wsl --install -d Ubuntu-22.04 -n nix-dotfiles-test
```

### Step 2: Enter WSL and run install (in WSL terminal)
```bash
# Update system (optional but recommended)
sudo apt update && sudo apt upgrade -y

# Clone and test
git clone https://github.com/atyrode/nix-dotfiles.git ~/nix-dotfiles
cd ~/nix-dotfiles
bash install.sh
```

### One-liner test (after WSL is set up)
```bash
git clone https://github.com/atyrode/nix-dotfiles.git ~/nix-dotfiles && cd ~/nix-dotfiles && bash install.sh
```

## Alternative: Test with existing WSL instance

If you already have WSL, you can test in a temporary directory:

```bash
# Create test directory
mkdir -p /tmp/nix-test
cd /tmp/nix-test

# Clone repo
git clone https://github.com/atyrode/nix-dotfiles.git .

# Modify install script to use test directory
export HOME_BACKUP=$HOME
export HOME=/tmp/nix-test-home
mkdir -p $HOME

# Run install (it will install to /tmp/nix-test-home/nix-dotfiles)
bash install.sh
```

## Quick validation checklist

After running install.sh, verify:
- [ ] Nix is installed: `nix --version`
- [ ] Flakes are enabled: `nix flake --version`
- [ ] Home Manager works: `home-manager --version`
- [ ] Shell functions load: `zsh -c "atyrode"`
- [ ] Packages are available: `which zoxide fzf bat`

## Cleanup test instance

```powershell
# In PowerShell (Windows)
wsl --unregister nix-dotfiles-test
```
