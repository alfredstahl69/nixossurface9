{ config, pkgs, ... }:

{
  # ==========================
  # 🔹 Import Configurations
  # ==========================
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
  ];

  # ==========================
  # 🔹 Boot Configuration (Systemd-Boot)
  # ==========================
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;  # Keep last 10 bootloader entries
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Btrfs Mount Options
  fileSystems."/".options = [ "compress=zstd" "subvol=@" ];
  fileSystems."/home".options = [ "compress=zstd" "subvol=@home" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" "subvol=@nix" ];
  fileSystems."/var/log".options = [ "compress=zstd" "subvol=@log" ];
  fileSystems."/var/cache".options = [ "compress=zstd" "subvol=@cache" ];
  fileSystems."/swap".options = [ "subvol=@swap" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EF3B-9CB0";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # ==========================
  # 🔹 System Settings
  # ==========================
  services.dbus.enable = true;
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };
  time.timeZone = "Europe/Berlin";

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable flakes & new nix commands
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ==========================
  # 🔹 Power Management (Battery Life)
  # ==========================
  services.thermald.enable = true;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
  hardware.cpu.intel.updateMicrocode = true;

  # Enable power-profiles-daemon (Better than TLP)
  services.power-profiles-daemon.enable = true;

  # ==========================
  # 🔹 Graphics & Touchscreen Support
  # ==========================
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver vaapiIntel vaapiVdpau ];
  };

  # Enable Touchscreen Support
  services.udev.packages = [ pkgs.iptsd ];
  systemd.packages = [ pkgs.iptsd ];

  # ==========================
  # 🔹 Bluetooth & Networking
  # ==========================
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ==========================
  # 🔹 Localization & Keyboard
  # ==========================
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

  # Improve Touchpad Experience
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    touchpad.accelProfile = "adaptive";
  };

  # ==========================
  # 🔹 Desktop & UI (Plasma 6)
  # ==========================
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # ==========================
  # 🔹 Audio & Media (PipeWire)
  # ==========================
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;  # Enables pro audio support (optional)
  };

  # Enable Printing Support
  services.printing.enable = true;

  # ==========================
  # 🔹 User Configuration
  # ==========================
  users.users.phil = {
    isNormalUser = true;
    description = "phil";
    extraGroups = [ "networkmanager" "surface-control" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Set Zsh as Default Shell
  programs.zsh.enable = true;

  # Install Firefox
  programs.firefox.enable = true;

  # ==========================
  # 🔹 Security & System Management
  # ==========================
  services.acpid.enable = true;

  # ==========================
  # 🔹 System Version (DO NOT CHANGE)
  # ==========================
  system.stateVersion = "24.11";
}
