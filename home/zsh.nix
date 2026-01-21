{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true; # Enable zsh-autosuggestions
    syntaxHighlighting.enable = true; # Enable zsh-syntax-highlighting

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "tmux"
      ];
    };

    # Load custom shell functions
    initContent = builtins.readFile ./shell/functions.zsh;
  };
  
  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
}
