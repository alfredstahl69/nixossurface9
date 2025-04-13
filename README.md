# Installing NixOS on a Surface Pro 9

This guide documents the process of installing NixOS on a Surface Pro 9 using Btrfs subvolumes. The steps include partitioning, mounting, installing, and setting up a reproducible configuration with Git. It also provides troubleshooting tips.

---

## 1️⃣ Setting up Git on a New Machine

```sh
git config --global user.name "alfred.stahl69"
git config --global user.email "alfred.stahl69@gmail.com"
```

To clone the repository and start working with it:

```sh
git clone https://github.com/alfredstahl69/nixossurface9.git
cd nixossurface9
```

To copy the files:

```sh
cp -r * /etc/nixos/
```

Then commit and push changes:

```sh
git add .
git commit -m "commit message"
git push origin main
```

---

## 2️⃣ Preparing the System for NixOS Installation

### Formatting the Partition

Use **GParted** to format the desired partition as **Btrfs**, or do it manually:

```sh
mkfs.btrfs /dev/sdX2  # Replace with actual partition
```

### Creating Btrfs Subvolumes

```sh
mount -o compress=zstd /dev/sdX2 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/log
btrfs subvolume create /mnt/cache
btrfs subvolume create /mnt/.snapshots
umount /mnt
```

### Mounting Subvolumes

```sh
mount -o compress=zstd,subvol=root /dev/sdX2 /mnt
mkdir -p /mnt/{home,nix,var/log,var/cache,.snapshots,boot}
mount -o compress=zstd,subvol=home /dev/sdX2 /mnt/home
mount -o compress=zstd,subvol=nix /dev/sdX2 /mnt/nix
mount -o compress=zstd,subvol=log /dev/sdX2 /mnt/var/log
mount -o compress=zstd,subvol=cache /dev/sdX2 /mnt/var/cache
mount -o compress=zstd,subvol=.snapshots /dev/sdX2 /mnt/.snapshots
mount /dev/sdX1 /mnt/boot/efi  # Replace with actual boot partition
```

### Generating Configuration

```sh
nixos-generate-config --root /mnt
```

### Installing NixOS

```sh
nixos-install
reboot
```

---

## 3️⃣ Post-Installation Setup

If booting into the system fails, switch to **TTY1** with `Ctrl + Alt + F1` and try a rebuild:

```sh
sudo nixos-rebuild switch --upgrade
```

Enable experimental features by adding this to `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Install Git if necessary:

```sh
sudo nix-env -iA nixpkgs.git
```

Clone the GitHub repository and copy the config:

```sh
git clone https://github.com/alfredstahl69/nixossurface9
sudo cp -r nixossurface9/* /etc/nixos/
```

Rebuild with:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos --bootloader-install
home-manager switch --flake /etc/nixos#phil
```

If something is broken, check UUIDs with:

```sh
lsblk -f
```

Modify `/etc/nixos/hardware-configuration.nix` accordingly.

---

## 4️⃣ Troubleshooting

- If the system fails to boot, use **TTY1** (`Ctrl + Alt + F1`) and rebuild.
- If necessary, enter the system from a **Live USB**:

```sh
mount -o subvol=root /dev/sdX2 /mnt
mount -o subvol=home /dev/sdX2 /mnt/home
mount -o subvol=nix /dev/sdX2 /mnt/nix
mount -o subvol=log /dev/sdX2 /mnt/var/log
mount -o subvol=cache /dev/sdX2 /mnt/var/cache
mount /dev/sdX1 /mnt/boot
nixos-enter --root /mnt
passwd phil  # Set password
```

- If the display manager isn’t working, enable KDE Plasma:

```nix
services.xserver.enable = true;
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
```

- Regenerate config if needed:

```sh
nixos-generate-config --root /mnt
```

---

## TL;DR

1️⃣ Boot into a **Live USB** and format the disk.
2️⃣ Create and mount **Btrfs subvolumes**.
3️⃣ Run `nixos-generate-config --root /mnt` and install.
4️⃣ After reboot, enable flakes, install Git, clone your repo.
5️⃣ Copy the repo contents to `/etc/nixos/`.
6️⃣ Run `sudo nixos-rebuild switch --flake /etc/nixos#nixos --bootloader-install`.
7️⃣ If issues arise, check UUIDs, rebuild from **TTY1**, or enter via **Live USB**.

This guide ensures a reproducible and structured installation process. 🚀  

  zu Beginn sollte folgendes in config.nix eingefügt werden:   services.snapper.configs."home" = {
  SUBVOLUME = "/home";
};
  
  bezüglich snapshots läuft das so ab:   sudo btrfs subvolume create /home/.snapshots/   then:   sudo snapper -c home create -d "insert name"  
  now we have a snapshot. to restore a specific snapshots you should be able to do this:   sudo snapper -c home rollback "n"  nevermiiiiiiiiinnnnnddd alles ungültig. nutz einfach btrfs assistant und es hat sich alles gegessen.  



    # 1. UUID der NixOS-ESP finden
lsblk -f

# 2. GRUB EFI-Dateipfad von NixOS finden
sudo efibootmgr -v | grep NixOS

# 3. In /etc/grub.d/40_custom einfügen:
menuentry "NixOS (chainload)" {
    insmod part_gpt
    insmod fat
    search --fs-uuid --set=root <UUID>
    chainloader /EFI/<Pfad-zur-GRUB-EFI>.efi
}

# 4. GRUB updaten
sudo update-grub


