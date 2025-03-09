{ config, pkgs, ... }:

{
  home.username = "phil";
  home.homeDirectory = "/home/phil";

  # ✅ Let Home Manager manage itself
  programs.home-manager.enable = true;

  xdg.enable = true;

  # ✅ Enable Zsh & Set It as Default Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # ✅ Improve Zsh experience
    initExtra = ''
      # Load Powerlevel10k (if installed)
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Better history search (Up/Down arrows)
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward

      # Enable directory navigation (like Fish)
      autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' rehash true
    '';

    # ✅ Useful Aliases
    shellAliases = {
      c = "cd /etc/nixos/";  
      s = "sudo nano";        
      reload = "home-manager switch --flake /etc/nixos#phil";
      reload-git = "home-manager switch --flake ~/nixossurface9#phil";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos && home-manager switch --flake /etc/nixos#phil";
      rebuild-git = "sudo nixos-rebuild switch --flake ~/nixossurface9#nixos && home-manager switch --flake ~/nixossurface9#phil";
      dry-rebuild-git = "sudo nixos-rebuild dry-run --flake ~/nixossurface9#nixos";
      dry-rebuild = "sudo nixos-rebuild dry-run --flake /etc/nixos#nixos";
      update-flake-git = "sudo nixos-rebuild switch --flake ~/nixossurface9#nixos";
      update-flake = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      garbage = "sudo nix-collect-garbage";
      garbage-more = "sudo nix-collect-garbage -d";
      rmgenerations = "sudo nix-env --delete-generations 7d";
      update = "sudo nix flake update --flake /etc/nixos";
      update-git = "sudo nix flake update --flake ~/nixossurface";  
      reboot = "sudo reboot";  
      shutdown = "sudo shutdown now";  
      rl = "source ~/.zshrc";
      ll = "ls -lah";  
      grep = "grep --color=auto";  
    };
  };

  # ✅ Apply settings
  home.stateVersion = "24.11";
}
