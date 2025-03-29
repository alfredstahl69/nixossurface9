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
but anyways. 
also if the rebuild doesnt work, then what would be smart would be to just copy the cloned files into /etc/nixos/ and then do it with the tradtional flake thingy whatever yes. 

okay update. I did install with btrfs the way that went over the terminal. it worked? kind of? basically doing  a rebuild inside tty1 fixed some problems. now the new commit includes the btrfs fixes, wether it works I dont know.  

okay just for quick info I did this here from chatgpt and it did work: 🛠 1️⃣ Boot into a NixOS Live USB

    Download a NixOS ISO and flash it to a USB drive (e.g., using dd or balenaEtcher).
    Boot from the USB by selecting it in your BIOS boot menu.
    Open a terminal.

🛠 2️⃣ Partition the Disk (GPT Layout)

Run this command to erase your disk and create new partitions:

printf "label: gpt\n,550M,U\n,,L\n" | sfdisk /dev/sdX

Replace /dev/sdX with your actual disk (e.g., /dev/nvme0n1 or /dev/sda).

    The first partition (/dev/sdX1) is 550MB (for EFI boot).
    The second partition (/dev/sdX2) uses the rest of the disk for Btrfs.

🛠 3️⃣ Format the Partitions
EFI Boot Partition

mkfs.fat -F 32 /dev/sdX1

Btrfs Root Partition

mkfs.btrfs /dev/sdX2

🛠 4️⃣ Create Btrfs Subvolumes

Mount the Btrfs partition first:

mount /dev/sdX2 /mnt

Now, create subvolumes for better system organization:

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@swap

Unmount when done:

umount /mnt

🛠 5️⃣ Mount the Subvolumes

Now, we mount everything properly:

mount -o compress=zstd,subvol=@ /dev/sdX2 /mnt
mkdir -p /mnt/{home,nix,var/log,var/cache,swap,boot}
mount -o compress=zstd,subvol=@home /dev/sdX2 /mnt/home
mount -o compress=zstd,noatime,subvol=@nix /dev/sdX2 /mnt/nix
mount -o compress=zstd,subvol=@log /dev/sdX2 /mnt/var/log
mount -o compress=zstd,subvol=@cache /dev/sdX2 /mnt/var/cache
mount -o subvol=@swap /dev/sdX2 /mnt/swap
mount /dev/sdX1 /mnt/boot

🛠 6️⃣ Generate the NixOS Configuration

Run:

nixos-generate-config --root /mnt

This will create /mnt/etc/nixos/configuration.nix and /mnt/etc/nixos/hardware-configuration.nix.
🛠 7️⃣ Update configuration.nix

Open the config file:

nano /mnt/etc/nixos/configuration.nix

Inside the fileSystems section, add this:

  fileSystems."/".options = [ "compress=zstd" "subvol=@" ];
  fileSystems."/home".options = [ "compress=zstd" "subvol=@home" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" "subvol=@nix" ];
  fileSystems."/var/log".options = [ "compress=zstd" "subvol=@log" ];
  fileSystems."/var/cache".options = [ "compress=zstd" "subvol=@cache" ];
  fileSystems."/swap".options = [ "subvol=@swap" ];

This ensures NixOS mounts everything correctly.
🛠 8️⃣ Install NixOS

Run:

nixos-install

Set a root password when prompted.
🛠 9️⃣ Reboot Into Your New System

reboot

After booting, log in and check that everything is working:

lsblk -f

✅ Extras (Optional but Recommended)
Enable Automatic Scrubbing (Filesystem Check)

Add this to configuration.nix:

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

Enable a Swap File

    Create a swap file:

btrfs filesystem mkswapfile --size 8g --uuid clear /swap/swapfile

    Add this to configuration.nix:

  swapDevices = [ { device = "/swap/swapfile"; } ];

    Run:

sudo nixos-rebuild switch  

now important to note was that it kind of worked? you have to login via life environment and nixos-enter /mnt after correctly mounting it as btrfs stuff which works like this:   
mount -o subvol=@ /dev/sdX2 /mnt
mount -o subvol=@home /dev/sdX2 /mnt/home
mount -o subvol=@nix /dev/sdX2 /mnt/nix
mount -o subvol=@log /dev/sdX2 /mnt/var/log
mount -o subvol=@cache /dev/sdX2 /mnt/var/cache
mount /dev/sdX1 /mnt/boot  



okay when in there it makes a lot of sense to add a user, you can also set a password quickly there with a simple password line. mine was this:   users.users.phil = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
  password = "mypassword"; # Change this!
  shell = pkgs.bash; # Or use pkgs.zsh if you prefer Zsh
};  

okay then what was relevant to do was adding kdeplasma like this:   # Enable X11 & Wayland
services.xserver.enable = true;

# Enable KDE Plasma 6
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;  

theoretically you can also already just put in the commit here buuuut probably not so smart since it easily breaks and the life environment isnt very happy with dbus and systemd. so I dont recommend oing that. alsooooo you have to check the uuids!!!!!!!!!!!! very important!! they will be different. so check with lsblk -f and change them in config.nix. right important also is to add the btrfs stuff inside configuration.nix following the commit.  

right if something went wrong this here also makes sense at times: nixos-generate-config --root /mnt  
okay so booting into it will likely not work. here is why: well I dont know, but I know how to fix it. for that just go into tty with ctrl + alt + f1 and exit it with f7; then you do a quick rebuild in there and it *should* work. what also makes sense would be while you are at it in there, to inlcude every other relevant shit. like times zones, keyboard all that and then do a rebuild. if you wanna be fancy you can also do a switch --upgrade.    

right also. the password can be set with:   passwd phil. cool!  

rebuilding from the cloned commit *should* be fine, though that requires testing I guess. lets see if something breaks...                                      


















right this all is kind of not important anymore. pretty sure I figured something new out. so the deal is we use the command line to install it all. first would be to format the partition with gparted to btrfs. then the plan would be to do this:     mount -o compress=zstd /dev/sdc3 /mnt    after that come this:     btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/log
btrfs subvolume create /mnt/cache    
and then we will also do this:     btrfs subvolume create /mnt/snapshots    and then unmount:     umount /mnt    
now this: Now, mount the root subvolume first:

mount -o compress=zstd,subvol=root /dev/sdc3 /mnt

Then create necessary directories and mount the rest:

mkdir -p /mnt/{home,nix,var/log,var/cache}
mount -o compress=zstd,subvol=home /dev/sdc3 /mnt/home
mount -o compress=zstd,subvol=nix /dev/sdc3 /mnt/nix
mount -o compress=zstd,subvol=log /dev/sdc3 /mnt/var/log
mount -o compress=zstd,subvol=cache /dev/sdc3 /mnt/var/cache

(If you made a snapshots subvolume)

mkdir -p /mnt/.snapshots
mount -o compress=zstd,subvol=snapshots /dev/sdc3 /mnt/.snapshots

    and obviously this with prob on the surface being nvme:    mkdir -p /mnt/boot
mount /dev/sdXn /mnt/boot  # Replace with actual boot partition (e.g., /dev/sdc1)

    then the plan is to do this:    nixos-generate-config --root /mnt    and then to copy my barebojne config.nix inside there, or rather to overwrite the created config.nix. and obviously check the hardwareconfig wether everything is inside there.     
    if everything makes sense then do this:     nixos-install    
    now it all should have worked, if not... well thats bad. anyway.    

    now the next plan is, after booting if stuff doest work use tty1 and do a rebuild, then it shhould work.     
    then log in, open the config.nix and enable experimental features and install git( actually I maybe should add that into my barebone config). anyway.     
    then please copy over the github stuff with     git clone https://github.com/alfredstahl69/nixossurface9    then obviously put in the password and stuff.    after that you may copy over the stuff from within the githuib clojned directory to /etc/nixos and please do so with:      sudo cp -r     
    now after that you may run:     sudo nixos-rebuild switch --flake /etc/nixos#nixos    
    and then it should work. I hope. you may also, after that, run:    home-manager switch --flake /etc/nixos#phil    
    and that should be it. I hope.
