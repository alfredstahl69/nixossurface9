# Installing NixOS on a surface pro 9 with intel chip, with btrfs and the minegrub theme :)

If you are here then you are either chronically on github or are actually interested in this topic. I only made this since I honestly didnt really find anything related to installing nixos on a surface that helped me (mostly since I really have no clue about NixOS in general i just find it cool(also Im a bit stupid)) anyway. point being I want nixos with btrfs so who do I ask? Someone in a Forum? Oh nah Im scared of people. Of course I ask chatgpt. and what you see here is all what chatgpt managed to do. which I admit didnt work. like at all. It literally crashed everything so sooo many times. (mostly since Im, as mentioned previously, stupid.) Well regardless, lots of tears, annoying chatgpt and yes also a bit of blood( dont ask) laterI got this all here. wether it actually works uh kinda? It kind of does. but I'll try to fix this all a bit. If anyone has smart replies please do so, I dont mind learning a bit. If anyone has questions.. dont come to me, I dont know what this all here does. Ask chatgpt, I guarantee you chatgpt will give you code that crashes you system. Hence my advice. Use NixOS. okay that was all over the place but i think you understand what this is about. Also if you read that all.. uh can I help you? you really read that all? wellp I hope you enjoyed that lol.
---


## Preparing the System

### Format the Partition

Use GParted or do it manually: Seriously just use gparted. so much easier. (Also this is all from chatgpt, I'll just add some nice comments to make it more digestable. or whatever..)

```bash
mkfs.btrfs /dev/nvmeXn1pY  # Seriously remeber to change the X and the Y. Also tripple check wether the numbers are correct. I once ended up with my windows boot partition in random places. good times. (dont ask how, I dont even know)
```

### Create Btrfs Subvolumes( or just use ext4 but at that point just use the installer srsly. I'll be so mad when the installer adds the option to use btrfs..)
 Temporarily mount root partition( no idea what this all is, either take it as such or ask chatgpt, also make sure ALL the X's and Y's are replace with their ACTUAL numbers)) Also I really recommend doing this after running sudo -i since Chatgpt didnt add sudo infront and I really cant be bothered to do so. Sorry.. well anyway. deal with it Ig.

```bash
mount -o compress=zstd /dev/nvmeXn1pY /mnt

# Create subvolumes
btrfs subvolume create /mnt/root       # Root filesystem
btrfs subvolume create /mnt/home       # Home directories
btrfs subvolume create /mnt/nix        # Nix store
btrfs subvolume create /mnt/log        # Log files
btrfs subvolume create /mnt/cache      # Cache
btrfs subvolume create /mnt/.snapshots # Snapshots
btrfs subvolume create /mnt/swap       # Swap subvolume (for swapfile)

# Unmount temporarily
umount /mnt
```

### Mount Subvolumes mounting again, yay. also CHECK THE DAMN NUMBERS

```bash
# Mount root and other subvolumes
mount -o compress=zstd,subvol=root /dev/nvmeXn1pY /mnt
mkdir -p /mnt/{home,nix,var/log,var/cache,.snapshots,swap,boot}

mount -o compress=zstd,subvol=home       /dev/nvmeXn1pY /mnt/home
mount -o compress=zstd,subvol=nix        /dev/nvmeXn1pY /mnt/nix
mount -o compress=zstd,subvol=log        /dev/nvmeXn1pY /mnt/var/log
mount -o compress=zstd,subvol=cache      /dev/nvmeXn1pY /mnt/var/cache
mount -o compress=zstd,subvol=.snapshots /dev/nvmeXn1pY /mnt/.snapshots

# Mount swap subvolume WITHOUT CoW (hehe cows. Did you know that Cows are actually really dangerous? pretty scary things..)
tmp_dir=/mnt/swap
mount -o subvol=swap,nodatacow,compress=no /dev/nvmeXn1pY $tmp_dir

# Mount EFI partition (yeah the efi directory probably doesnt exist so you'll have to add it. actually lemme just place a command here...)
mkdir -p /mnt/boot/efi
mount /dev/nvmeXn1p1 /mnt/boot/efi
```

---

# Initial Installation & Swapfile Setup (yeah imma be honest, the swap thing probably doesnt work since I configured that incorrectly. No idea how to do it correctly tho. If anyone has tips lemme know. I'll fix it then. maybe. Im lazy. living without swap should be possible..)

 Generate NixOS configuration files. right important here to note is that the config is the very basic nixos config. So I made another one which you'll find in the Barebones Directory. you can just copy that over there. also read the comments there. if you want to obviously. tho dont come crying to me later after not reading it...

```bash
 nixos-generate-config --root /mnt
```

> **Note**: Do **not** run `nixos-install` yet; first set up the swapfile. No Idea why chatgpt put that here, but Imma just keep it lol

# Create the swapfile (12 GiB) using Btrfs tool ( depends on what you have as RAM, mine has 12gb, which every surface pro 9 has.. so its kinda irrelevant to mention.. but uh yeah. wanted to say something :}) 

```bash
cd /mnt/swap
btrfs filesystem mkswapfile --size 12G --uuid clear swapfile
chmod 600 swapfile

# Test activating swap( why? no idea. just do it. chatgpt said so, and I do everything an AI tells me to, jk I dont and neither should you)
swapon swapfile
swapon --show  # Should display ~12G swap
swapoff swapfile
```

---

##Configure Swap in `configuration.nix` (yeah i kinda already did that in the barebones config, but you need to tweak something yourself so I will keep this whole section here. Dooont worry I'll show you what todo. well chatgpt will tell me and then I'll tell you. Just worse and with many grammatical error. English isnt my first language so please be nice)

Edit `/mnt/etc/nixos/configuration.nix` (or your flake-based config, you dont have a flake based config... yet) and add:

```nix
{ config, pkgs, ... }:
{
  # Swapfile definition
  swapDevices = [
    {
      device = "/swap/swapfile";  # Path inside the mount
      size   = 12288;              # Size in MiB (12 GiB)
    }
  ];

  # Hibernate (Suspend-to-Disk) support
  boot.kernelParams = [
    "resume=/swap/swapfile"
    # Replace OFFSET with the value found via filefrag:
    # e.g. filefrag -v /swap/swapfile | awk '$1=="0:"{print $4}' (here thats the important part. copy that command and run it. that will give you a random number with three dots at the end. just copy that number without the dots and replace OFFSET with that number. I think thats how its supposed to be at least...)
    "resume_offset=OFFSET"
  ];
}
```

After saving, run: ( yeah just do as it says here. If something doesnt work then uh. yeah Ive been there. My hint? give up. No Im just kididng. Never give up. copy the entire error( I know thats not necessary but we want to annoy Sir GPT) and then paste it into chatgpt. With like 10 years worth of luck you'll actually get a helpful answer that doesnt destroy your entire existence. ( honestly if you know whats going on it probably also wont get destroyed.. but I have no idea whats going on. so. yeah. anyways.)

```bash
sudo nixos-install
```
# assuming that you wont have errors you'll need to put in a root password at the end. Remember to check your keyboard layout. I use the german keyboard layout, so had quite a lot of issues there as you might be able to imagine... and a>


---

## Post-Installation

# Ensure system is up-to-date
#sudo nixos-rebuild switch --upgrade yeah honestly dont do it like that ( I know I could delete it but nah, instead what you wanna do now is to copy everything from the NixOSFinale directory into /etc/nixos/. and then you wanna do this:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos 
```
that should install everything necessary. however. uh what I didnt mention is that that will take.. like prob 2-3 hours? Make sure you have lots of time and a really good internet connection. also uh check your power. the surface real>

Right back on topic. actually with that you didnt update the system. get trolled :) Basically thats defined by the flake.lock file you copied. thats updated with:
```bash

sudo update flake
```

 at least I think. also in order for it to work you'll need to be in the /etc/nixos directory. anyway. that will update everything and then you'll need to run the previous rebuild command.


Enable flakes support if not yet enabled: ( yeah no need to worry about that thats all already included. Chatgpt just added it here and I ddint want to delete it.

```nix
# In /etc/nixos/configuration.nix or flake inputs
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Install Git if missing:

```bash
sudo nix-env -iA nixpkgs.git
```

Reclone repo & rebuild:

```bash
git clone https://github.com/alfredstahl69/nixossurface9
sudo cp -r nixossurface9/* /etc/nixos/

sudo nixos-rebuild switch --flake /etc/nixos#nixos
home-manager switch --flake /etc/nixos#phil 
```

yeah you may do that all. As you can see homemanager is included and you may check the home.nix file and change it however you want. Dont go complaining to me with anything there. I dont know whats going on there either. Also I added aliases into home.nix so all the commands are easier to do. just check home.nix. (and yes I actually did that not chatgpt, crazy I know.)

---

## GRUB & Minegrub Theme ( If you dont like minegrub then.. f u. No Im kidding. its personal taste so its cool. Just change it to whatever you want. If you dont know how todo that. Dont ask me. I dont know either. ask chatgpt. my advice there would be to look up the theme you want on the internet and then to see wether they have a flakes integration. and then you mayb copy that and the flake.nix files into chatgpt and tell it to merge them. chatgpt will never really find anything helpful if you let it search.)

### Flake Inputs for Minegrub ( yeah u may ignore that too since its all already in the flake you copied. I just kept it here because there are a few things that arent in my flake, you'll see. Just keep on reading.)

```nix
minegrub-theme.url = "github:Lxtharia/minegrub-theme";
```

### Include Modules

```nix
minegrub-theme.nixosModules.default
```

### GRUB Configuration in `configuration.nix`

```nix
boot.loader.grub = {
  enable = true;
  version = 2;
  device = "nodev";
  minegrub-theme = {
    enable = true;
    splash = "100% Flakes!";
    background = "background_options/1.20 - [Trails & Tales].png";
    boot-options-count = 2; # if you have more boot options you'll need to change that. I will be changing it. 2 is for nixos and the advanced options. if you want to add chainloading you'll need a third one here. I will be using chainloading. I dont even know if I use that word correctly.. as you miught be able to tell I have to idea what it actually means. also good luck deleting that comment when you copy this all onto your system hehe~)
  };
  extraEntries = ''
    menuentry "UEFI Firmware Settings" { fwsetup }
    menuentry "Reboot" { reboot }
    menuentry "Shutdown" { halt }
    menuentry "Boot Garuda" {
      insmod part_gpt
      insmod fat
      search --fs-uuid 5D48-3DE2 --set=root
      chainloader /EFI/Garuda/grubx64.efi
    }
  '';
};
```
if you want to use all these extra menuentries you may, but remember to change the boot options count( naturally you can also change the background with ease, I just like that one) Also the chainloading can be changed however you want it to be. I simply have garudalinux on my surface too so thats what it is for me. btw I dont use the osprober since nixos doesnt detect garuda and garuda doesnt detect nixos. No idea why. Im too lazy to fix it and the chainloading thing is actually pretty cool. So I'll stick with that. Obviously you dont have to and can easily change that. How you may ask? No idea. Ask Chatgpt.
---

## Troubleshooting & Recovery ( you dont want to know how many hours I spent on troubleshooting and stuff. Well actually not many, most of the time was either spent trying to make chatgpt understand whats going on or crying.)

Follow live USB recovery steps and mount as above. Use `nixos-enter` if needed.
yeah if anything goes wrong just got into a live environment.and obv you'll need to do nixos enter. and just as it said the mounting steps from above. simply follow them. but remember to check the correcnt names of the partitions with lsblk or lsblk -f if you are cool.
---

##Snapshots & Maintenance (snapshots are cool. thats my comment here. Another thing would be that I have no idea why chatgpt put that here or what its meant to tell me.)

Use **Btrfs Assistant** or `btrfs` CLI for snapshots under `/mnt/.snapshots`.
anyway. if you want snapshots working just open the btrfs assistant and voila it'll work. hopefully. well if you have my configuration that is. snapper should be correctly configured. Also I know snapshotting( is that even a word) the root partition isnt smart and wont really work. since nixos. But I still have it included. Because funny. So deal with it. Or delete it. Whatever.
---

## TL;DR No Idea why and what thats for. So I'll leave it here and make a very stupid comment. Nice.

1. Format & mount Btrfs subvolumes (including `swap` subvolume).
2. Generate config but **delay** `nixos-install` until swapfile is in place.
3. Create 12 GiB swapfile in `swap` subvolume and test.
4. Add `swapDevices` and `boot.kernelParams` to `configuration.nix`.
5. Run `nixos-install` and enjoy Hibernate on your Surface Pro 9.
6. Add Minegrub for a fancy GRUB theme.
