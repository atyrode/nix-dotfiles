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
