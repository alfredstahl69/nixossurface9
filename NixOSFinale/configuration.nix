{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.useOSProber = false;

  boot.loader.grub.extraEntries = ''
    menuentry "Multiplayer" {
      insmod part_gpt
      insmod fat
      search --fs-uuid 6C69-6009 --set=root
      chainloader /EFI/Garuda/grubx64.efi
    }
  '';

  boot.loader.grub.minegrub-theme = {
    enable = true;
    splash = "100% Flakes!";
    background = "background_options/1.20 - [Trails & Tales].png";
    boot-options-count = 3;
  };

  boot.loader.efi.efiSysMountPoint = "/boot/efi/";
  boot.loader.grub.configurationName = "NixOS";
  #boot.loader.grub.efiBootloaderId = "NixOS";

  services.snapper.configs."home" = {
    SUBVOLUME = "/home";
  };

  services.snapper.configs."root" = {
    SUBVOLUME = "/";
  };

  services.dbus.enable = true;
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };
  time.timeZone = "Europe/Berlin";

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.thermald.enable = true;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
  hardware.cpu.intel.updateMicrocode = true;

  services.power-profiles-daemon.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver vaapiIntel vaapiVdpau ];
  };

  services.udev.packages = [ pkgs.iptsd ];
  systemd.packages = [ pkgs.iptsd ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de";
  services.xserver.xkb.layout = "de";

  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    touchpad.accelProfile = "adaptive";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.printing.enable = true;

  users.users.phil = {
    isNormalUser = true;
    description = "phil";
    extraGroups = [ "networkmanager" "surface-control" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ kdePackages.kate ];
  };

  programs.zsh.enable = true;
  programs.firefox.enable = true;

  services.acpid.enable = true;
  networking.firewall.enable = true;
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 53317 -s 192.168.178.0/24 -j ACCEPT
    iptables -A nixos-fw -p udp --dport 53317 -s 192.168.178.0/24 -j ACCEPT
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;


#  networking.firewall.allowedTCPPorts = [ 53317 ];
#  networking.firewall.allowedUDPPorts = [ 53317 ];

  boot.resumeDevice = "/dev/disk/by-uuid/d5e2c028-403f-4a8e-a451-819ffc9075d4";
  system.stateVersion = "24.11";

}
