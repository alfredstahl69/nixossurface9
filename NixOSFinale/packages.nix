{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.plasma-browser-integration
    mullvad-browser
    libreoffice
    powertop 
    file lsof psmisc usbutils 
    libwacom
    nix-du
    nix-index
    acpid
    dbus
    util-linux
    btrfs-progs
    btrfs-assistant
#    grub2
    vim
    wget
    curl
    gparted
    btop
    fastfetch
    iptsd  # Touchscreen driver
    surface-control  # Surface power control
    xournalpp
    localsend
    git
    firefox
    neofetch
    home-manager
    thermald
    linux-firmware
  ];
}
