# 🚀 Installing NixOS on a Surface Pro 9

This guide documents the process of installing NixOS on a Surface Pro 9 using Btrfs subvolumes and a reproducible Git-based setup. It includes partitioning, installation, post-setup, and even how to make your GRUB menu look awesome with Minegrub 🟦🟨

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
cp -r * /etc/nixos/
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
mount -o compress=zstd /dev/nvmeXn1pY /mnt
btrfs subvolume create /mnt/root      # Root filesystem
btrfs subvolume create /mnt/home      # User home directories
btrfs subvolume create /mnt/nix       # Nix store
btrfs subvolume create /mnt/log       # Log files
btrfs subvolume create /mnt/cache     # Cache
btrfs subvolume create /mnt/.snapshots # For future snapshots
umount /mnt
```

### Mount Subvolumes

```bash
mount -o compress=zstd,subvol=root /dev/nvmeXn1pY /mnt
mkdir -p /mnt/{home,nix,var/log,var/cache,.snapshots,boot}
mount -o compress=zstd,subvol=home /dev/nvmeXn1pY /mnt/home
mount -o compress=zstd,subvol=nix /dev/nvmeXn1pY /mnt/nix
mount -o compress=zstd,subvol=log /dev/nvmeXn1pY /mnt/var/log
mount -o compress=zstd,subvol=cache /dev/nvmeXn1pY /mnt/var/cache
mount -o compress=zstd,subvol=.snapshots /dev/nvmeXn1pY /mnt/.snapshots
mount /dev/nvmeXn1p1 /mnt/boot/efi  # Mount EFI partition
```

---

## 3️⃣ Installation & Configuration

```bash
# Generate initial configuration
nixos-generate-config --root /mnt

# Install NixOS
nixos-install
reboot
```

### After First Boot

```bash
# Make sure your system is up-to-date
sudo nixos-rebuild switch --upgrade
```

Enable flakes support:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Install Git (if missing):

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

Check UUIDs if needed:

```bash
lsblk -f
```

---

## 4️⃣ Troubleshooting

### Live USB Recovery

```bash
# Mount root and other subvolumes
mount -o subvol=root /dev/nvmeXn1pY /mnt
mount -o subvol=home /dev/nvmeXn1pY /mnt/home
mount -o subvol=nix /dev/nvmeXn1pY /mnt/nix
mount -o subvol=log /dev/nvmeXn1pY /mnt/var/log
mount -o subvol=cache /dev/nvmeXn1pY /mnt/var/cache
mount /dev/nvmeXn1p1 /mnt/boot

# Enter system
nixos-enter --root /mnt
passwd phil  # Reset user password if needed
```

### KDE Plasma Display Manager

```nix
services.xserver.enable = true;
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
```

---

## 5️⃣ Snapshots

Use **Btrfs Assistant** for easy snapshot management — it’s much more intuitive than Snapper.

---

## 6️⃣ GRUB Chainloading (Multi-Distro Boot)

1. Find NixOS ESP UUID:

```bash
lsblk -f
```

2. Find NixOS EFI path:

```bash
sudo efibootmgr -v | grep NixOS
```

3. Add to `/etc/grub.d/40_custom` on another system:

```bash
menuentry "NixOS (chainload)" {
    insmod part_gpt
    insmod fat
    search --fs-uuid <UUID> --set=root
    chainloader /EFI/NIXOS-BOOT-EFI-/GRUBX64.EFI
}
```

4. Update GRUB:

```bash
sudo update-grub
```

---

## 7️⃣ Bonus: 🟨 Minegrub Theme

Give your GRUB a Minecraft-inspired twist!

### Flake Input:

```nix
minegrub-theme.url = "github:Lxtharia/minegrub-theme";
```

### In Modules:

```nix
minegrub-theme.nixosModules.default
```

### In `configuration.nix`:

```nix
boot.loader.grub.minegrub-theme = {
  enable = true;
  splash = "100% Flakes!";
  background = "background_options/1.20 - [Trails & Tales].png";
  boot-options-count = 2;
};
```

Make sure your theme files are accessible and paths match correctly.

---

## TL;DR

1. Boot Live USB, format & mount Btrfs subvolumes  
2. Generate config & install  
3. Enable flakes & Git, clone repo  
4. Copy configs & rebuild with `--flake`  
5. Chainload via GRUB if needed  
6. Add Minegrub for some ✨ extra flavor

wenn nun noch mehr grub einträge rein sollen, dann ganz einfach folgenes in config.nix einfügen, dabei aber halt auf uuids achten und natürlich bei minegrub die anzahl der einträge anpassen.   

    # Custom GRUB-Einträge hinzufügen
    boot.loader.grub.extraEntries = ''
        # Boot ins UEFI-Firmware-Setup (BIOS)
        menuentry "UEFI Firmware Settings" {
            fwsetup
        }

        # Reboot direkt aus GRUB
        menuentry "Reboot" {
            reboot
        }

        # Shutdown direkt aus GRUB
        menuentry "Shutdown" {
            halt
        }

        # Garuda Linux GRUB-Chainloading
        menuentry "Boot Garuda" {
            insmod part_gpt
            insmod fat
            search --fs-uuid --set=root 5D48-3DE2  # UUID der Garuda-ESP
            chainloader /EFI/Garuda/grubx64.efi
        }
     '';  
