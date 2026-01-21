{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    initContent = builtins.readFile ./shell/functions.zsh;
  };
  
  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
}
