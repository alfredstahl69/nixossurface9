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

  boot.loader.grub.minegrub-theme = {
    enable = true;
    splash = "100% Flakes!";
    background = "background_options/1.20 - [Trails & Tales].png";
    boot-options-count = 2;
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

  # Swapfile definition for 12 GiB (Added for Hibernate) <<< MARKED CHANGE >>>
  swapDevices = [
    {
      device = "/swap/swapfile";  # adjust if your swap subvolume mountpoint differs <<< REVIEW UUID/Path >>>
      size   = 12288;              # Size in MiB (12 GiB)
    }
  ];

  # Hibernate (Suspend-to-Disk) support <<< MARKED CHANGE >>>
  boot.kernelParams = [
    "resume=/swap/swapfile"     # adjust path if needed <<< REVIEW PATH >>>
    "resume_offset=269568"       # replace OFFSET via: filefrag -v /swap/swapfile | awk '$1=="0:"{print $4}' <<< INSERT ACTUAL OFFSET >>>
  ];

  system.stateVersion = "24.11";

}
