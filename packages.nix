{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    acpid
#    tlp
#    tlpui
    grub2
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
