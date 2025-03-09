# nixossurface9
Installing NixOS on my surface pro 9


setting up git on a new machine: git config --global user.name alfred.stahl69      
git config --global user.email alfred.stahl69@gmail.com

cloning git: git clone https://github.com/alfredstahl69/nixossurface9.git
then cd into it  
then copy the files tip: /* copys everything  
then do this: git add .  
then: git commit -m "name"  
then: git push origin main  

first dont forget to add this to config.nix:   nix.settings.experimental-features = [ "nix-command" "flakes" ];  
then best to do a sudo nixos-rebuild switch --upgrade  
now we can do git clone   
dont forget to change to the new uuid!!!  



