# 🚀 Installing NixOS on a Surface Pro 9

This guide documents the process of installing NixOS on a Surface Pro 9 using Btrfs subvolumes, a swapfile for hibernation, and a reproducible Git-based setup. It includes partitioning, installation, swap setup, post-setup, and even how to make your GRUB menu look awesome with Minegrub 🟦🟨

---

## 1️⃣ Set up Git on a New Machine

```bash
# Configure your Git user details
git config --global user.name "alfred.stahl69"
git config --global user.email "alfred.stahl69@gmail.com"

# Clone your configuration repository
git clone https://github.com/alfredstahl69/nixossurface9.git
cd nixossurface9

# Copy the configuration into place
sudo cp -r * /etc/nixos/
```

To commit and push changes later:

```bash
git add .
git commit -m "commit message"
git push origin main
```

---

## 2️⃣ Preparing the System

### Format the Partition

Use GParted or do it manually:

```bash
mkfs.btrfs /dev/nvmeXn1pY  # Replace with your actual partition
```

### Create Btrfs Subvolumes

```bash
# Temporarily mount root partition
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

### Mount Subvolumes

```bash
# Mount root and other subvolumes
mount -o compress=zstd,subvol=root /dev/nvmeXn1pY /mnt
mkdir -p /mnt/{home,nix,var/log,var/cache,.snapshots,swap,boot}

mount -o compress=zstd,subvol=home       /dev/nvmeXn1pY /mnt/home
mount -o compress=zstd,subvol=nix        /dev/nvmeXn1pY /mnt/nix
mount -o compress=zstd,subvol=log        /dev/nvmeXn1pY /mnt/var/log
mount -o compress=zstd,subvol=cache      /dev/nvmeXn1pY /mnt/var/cache
mount -o compress=zstd,subvol=.snapshots /dev/nvmeXn1pY /mnt/.snapshots

# Mount swap subvolume WITHOUT CoW
tmp_dir=/mnt/swap
mount -o subvol=swap,nodatacow,compress=no /dev/nvmeXn1pY $tmp_dir

# Mount EFI partition
mount /dev/nvmeXn1p1 /mnt/boot/efi
```

---

## 3️⃣ Initial Installation & Swapfile Setup

```bash
# Generate NixOS configuration files\ nixos-generate-config --root /mnt
```

> **Note**: Do **not** run `nixos-install` yet; first set up the swapfile.

```bash
# Create the swapfile (12 GiB) using Btrfs tool
cd /mnt/swap
btrfs filesystem mkswapfile --size 12G --uuid clear swapfile
chmod 600 swapfile

# Test activating swap
swapon swapfile
swapon --show  # Should display ~12G swap
swapoff swapfile
```

---

## 4️⃣ Configure Swap in `configuration.nix`

Edit `/mnt/etc/nixos/configuration.nix` (or your flake-based config) and add:

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
    # e.g. filefrag -v /swap/swapfile | awk '$1=="0:"{print $4}'
    "resume_offset=OFFSET"
  ];
}
```

After saving, run:

```bash
sudo nixos-install
reboot
```

---

## 5️⃣ Post-Installation

```bash
# Ensure system is up-to-date
sudo nixos-rebuild switch --upgrade
```

Enable flakes support if not yet enabled:

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

sudo nixos-rebuild switch --flake /etc/nixos#nixos --bootloader-install
home-manager switch --flake /etc/nixos#phil
```

---

## 6️⃣ GRUB & Minegrub Theme

### Flake Inputs for Minegrub

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
  device = "/dev/nvmeXn1";
  minegrub-theme = {
    enable = true;
    splash = "100% Flakes!";
    background = "background_options/1.20 - [Trails & Tales].png";
    boot-options-count = 2;
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

---

## 7️⃣ Troubleshooting & Recovery

Follow live USB recovery steps and mount as above. Use `nixos-enter` if needed.

---

## 8️⃣ Snapshots & Maintenance

Use **Btrfs Assistant** or `btrfs` CLI for snapshots under `/mnt/.snapshots`.

---

## TL;DR

1. Format & mount Btrfs subvolumes (including `swap` subvolume).
2. Generate config but **delay** `nixos-install` until swapfile is in place.
3. Create 12 GiB swapfile in `swap` subvolume and test.
4. Add `swapDevices` and `boot.kernelParams` to `configuration.nix`.
5. Run `nixos-install` and enjoy Hibernate on your Surface Pro 9.
6. Add Minegrub for a fancy GRUB theme.
