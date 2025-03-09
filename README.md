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
once copied rebuilding should be made like this: sudo nixos-rebuild switch --flake ~/nixossurface9#nixos  
and with this: home-manager switch --flake ~/nixossurface9#phil  
buuuuuut what would make sense would be to add to the first one the --bootloader-install flag, since we havent done that yet. so use this command at first:sudo nixos-rebuild switch --flake ~/nixossurface9#nixos --bootloader-install  
wether this works or not I have absolutly no fckng clue.  
but anyways. before that all chatgpt also  says that configuring btrfs would be important. which I dont think so since it fckng kills everything but whatever lets see.  
also if the rebuild doesnt work, then what would be smart would be to just copy the cloned files into /etc/nixos/ and then do it with the tradtional flake thingy whatever yes. I dont trust chatgpt...  

okay update. I did install with btrfs the way that went over the terminal. it worked? kind of? basically doing  a rebuild inside tty1 fixed some problems. now the new commit includes the btrfs fixes, wether it works I dont know.  



