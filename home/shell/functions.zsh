############################################
# Colors
############################################

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC="\033[0m"

c_ok()     { echo -e "${GREEN}$1${NC}"; }
c_ko()     { echo -e "${RED}$1${NC}"; }
c_folder() { echo -e "${CYAN}$1${NC}"; }
c_file()   { echo -e "${YELLOW}$1${NC}"; }

############################################
# Utils
############################################

prompt_yes_no() {
  local prompt_message=$1
  local answer
  while true; do
    echo -n "$prompt_message (y/n): "
    read answer
    case $answer in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

############################################
# Shell behavior & aliases
############################################

alias cl="clear"
alias htop="btop"
alias ls="tree -L 1 --noreport"

# zoxide replaces cd
eval "$(zoxide init zsh)"

# fzf Ctrl+R
eval "$(fzf --zsh)"

############################################
# Python helpers
############################################

alias python="python3"
alias pip="pip3"
alias py="python3"
alias pymake="uv pip install -e ."

############################################
# Python venv manager
############################################

VENV_DIR=".venv"
GITIGNORE=".gitignore"

_update_venv_vars() {
  PARENT_DIR=$(basename "$(pwd)")
}

_venv_exists() { [[ -d "$VENV_DIR" ]]; }
_venv_is_active() { [[ -n "$VIRTUAL_ENV" ]]; }

_create_venv() {
  if command -v uv >/dev/null; then
    c_ok "Using uv to create venv"
    uv venv
  else
    python3 -m venv "$VENV_DIR"
  fi
}

_activate_venv() {
  source "$VENV_DIR/bin/activate"
  c_ok "Activated venv"
}

_deactivate_venv() {
  deactivate
  c_ko "Deactivated venv"
}

_setup_gitignore() {
  [[ -f "$GITIGNORE" ]] || touch "$GITIGNORE"
  grep -q "^$VENV_DIR$" "$GITIGNORE" || echo "$VENV_DIR" >> "$GITIGNORE"
}

venv() {
  _update_venv_vars
  if _venv_is_active; then
    _deactivate_venv
  elif _venv_exists; then
    _activate_venv
  else
    if prompt_yes_no "Create venv in $PARENT_DIR?"; then
      _create_venv
      _setup_gitignore
      _activate_venv
    fi
  fi
}

pipreq() {
  _venv_is_active || venv || return 1
  if command -v uv >/dev/null; then
    uv pip install -r requirements.txt
  else
    pip install -r requirements.txt
  fi
}
alias pipr="pipreq"

pipfreeze() {
  _venv_is_active || return 1
  if command -v uv >/dev/null; then
    uv pip freeze > requirements.txt
  else
    pip freeze > requirements.txt
  fi
}
alias pipf="pipfreeze"

pipdel() {
  _venv_is_active || return 1
  if command -v uv >/dev/null; then
    uv pip freeze | xargs uv pip uninstall -y
  else
    pip freeze | xargs pip uninstall -y
  fi
}
alias pipd="pipdel"

revenv() {
  local target_dir="${1:-$(pwd)}"
  local original_dir="$(pwd)"

  if [[ ! -d "$target_dir" ]]; then
    c_ko "Directory does not exist: $target_dir"
    return 1
  fi

  cd "$target_dir" || return 1
  _update_venv_vars

  # Deactivate if active
  if _venv_is_active; then
    _deactivate_venv
  fi

  # Remove existing venv
  if [[ -d "$VENV_DIR" ]]; then
    c_folder "Removing existing venv in $PARENT_DIR"
    rm -rf "$VENV_DIR"
  fi

  # Recreate venv
  _create_venv
  _setup_gitignore
  _activate_venv

  # Reinstall requirements if present
  if [[ -f requirements.txt ]]; then
    pipreq
  fi

  cd "$original_dir" || return 1
}

unvenv() {
  local target_dir="${1:-$(pwd)}"
  local original_dir="$(pwd)"

  if [[ ! -d "$target_dir" ]]; then
    c_ko "Directory does not exist: $target_dir"
    return 1
  fi

  cd "$target_dir" || return 1

  # Deactivate if active
  if [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate
    c_ko "Deactivated virtual environment"
  fi

  # Remove venv directory
  if [[ -d "$VENV_DIR" ]]; then
    rm -rf "$VENV_DIR"
    c_folder "Removed virtual environment: $VENV_DIR"
  else
    c_ko "No virtual environment found in $(basename "$target_dir")"
    cd "$original_dir"
    return 1
  fi

  cd "$original_dir" || return 1
}

############################################
# Git helpers
############################################

hub() {
  local repo=$1
  git clone "https://github.com/atyrode/$repo.git" || return 1
  cd "$repo" || return 1
  [[ -d venv ]] && venv
  [[ -f requirements.txt ]] && pipreq
}

############################################
# Shell utilities
############################################

zconf() {
  # If a venv is active, deactivate it first
  if [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate
    echo -e "$(c_ok Deactivated) virtual environment."
  fi

  # Clear aliases (keeps your old behavior)
  unalias -a

  # Find the flake directory:
  # - uses $NIX_DOTFILES if you set it
  # - otherwise tries current dir, then ~/nix-dotfiles
  local flake_dir="${NIX_DOTFILES:-}"
  if [[ -z "$flake_dir" ]]; then
    if [[ -f "./flake.nix" ]]; then
      flake_dir="$PWD"
    elif [[ -f "$HOME/nix-dotfiles/flake.nix" ]]; then
      flake_dir="$HOME/nix-dotfiles"
    else
      echo -e "$(c_ko Could not find flake.nix). Set NIX_DOTFILES or run from the repo."
      return 1
    fi
  fi

  echo -e "$(c_folder Switching) Home Manager from: $flake_dir"
  nix run home-manager -- switch --flake "$flake_dir#alex" || {
    echo -e "$(c_ko Home Manager switch failed)"
    return 1
  }

  # Reload HM session vars (PATH, etc.) then restart login shell
  if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
    source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  fi

  exec zsh -l
}

atmux() {
  tmux attach-session -t "$1"
}

############################################
# Help function - lists all dotfiles content
############################################

atyrode() {
  # Find the dotfiles directory (same logic as zconf)
  local flake_dir="${NIX_DOTFILES:-}"
  if [[ -z "$flake_dir" ]]; then
    if [[ -f "./flake.nix" ]]; then
      flake_dir="$PWD"
    elif [[ -f "$HOME/nix-dotfiles/flake.nix" ]]; then
      flake_dir="$HOME/nix-dotfiles"
    else
      echo -e "$(c_ko Could not find flake.nix). Set NIX_DOTFILES or run from the repo."
      return 1
    fi
  fi

  local packages_file="$flake_dir/home/packages.nix"
  local functions_file="$flake_dir/home/shell/functions.zsh"
  local git_file="$flake_dir/home/git.nix"
  local zsh_file="$flake_dir/home/zsh.nix"

  echo -e "\n$(c_folder "==== Nix Dotfiles Help ====")\n"

  # Extract and display packages (simple text parsing - works reliably)
  if [[ -f "$packages_file" ]]; then
    echo -e "$(c_ok "📦 Installed Packages:")"
    awk '/home\.packages = with pkgs; \[/,/\];/ {
      if ($0 !~ /^[[:space:]]*#/ && $0 !~ /^[[:space:]]*\[/ && $0 !~ /^[[:space:]]*\]/ && $0 !~ /^[[:space:]]*$/) {
        gsub(/^[[:space:]]+|[[:space:]]+$|,$/, "", $0)
        if ($0 ~ /^[a-zA-Z0-9_]+$/) {
          print $0
        }
      }
    }' "$packages_file" | \
      while read -r pkg; do
        [[ -n "$pkg" ]] && echo -e "  $(c_file "•") $pkg"
      done
    echo ""
  fi

  # Extract and display shell functions
  if [[ -f "$functions_file" ]]; then
    echo -e "$(c_ok "🔧 Custom Shell Functions:")"
    grep -E '^[a-zA-Z_][a-zA-Z0-9_]*\(\)' "$functions_file" | \
      sed 's/() {.*$//' | \
      sed 's/^[[:space:]]*//' | \
      while read -r func; do
        # Skip internal/private functions starting with _
        [[ "$func" =~ ^_ ]] && continue
        echo -e "  $(c_file "•") $func"
      done
    echo ""
  fi

  # Extract and display aliases from functions.zsh
  if [[ -f "$functions_file" ]]; then
    echo -e "$(c_ok "🔗 Shell Aliases:")"
    grep -E '^alias [a-zA-Z_][a-zA-Z0-9_]*=' "$functions_file" | \
      sed 's/alias //' | \
      sed 's/=.*$//' | \
      while read -r alias_name; do
        echo -e "  $(c_file "•") $alias_name"
      done
    echo ""
  fi

  # Extract and display git aliases
  if [[ -f "$git_file" ]]; then
    echo -e "$(c_ok "🔀 Git Aliases:")"
    grep -E 'alias\.[a-zA-Z_][a-zA-Z0-9_]*\s*=' "$git_file" | \
      sed 's/alias\.//' | \
      sed 's/\s*=.*$//' | \
      sed 's/^[[:space:]]*//' | \
      while read -r git_alias; do
        echo -e "  $(c_file "•") git $git_alias"
      done
    echo ""
  fi

  # Extract and display zsh plugins
  if [[ -f "$zsh_file" ]]; then
    echo -e "$(c_ok "🎨 Zsh Plugins:")"
    awk '/plugins = \[/,/\]/ {
      if ($0 ~ /"[a-zA-Z0-9_-]+"/) {
        match($0, /"([^"]+)"/, arr)
        if (arr[1] != "") print arr[1]
      }
    }' "$zsh_file" | \
      while read -r plugin; do
        [[ -n "$plugin" ]] && echo -e "  $(c_file "•") $plugin"
      done
    echo ""
  fi

  # Display additional info
  echo -e "$(c_ok "💡 Quick Commands:")"
  echo -e "  $(c_file "•") zconf    - Reload dotfiles configuration"
  echo -e "  $(c_file "•") atyrode  - Show this help message"
  echo ""
  echo -e "$(c_folder "Dotfiles location: $flake_dir")\n"
}

############################################
# Startup footer
############################################

neofetch
