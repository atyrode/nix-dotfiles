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
