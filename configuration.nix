{ config, pkgs, ... }:

{
  # ==========================
  # 🔹 Import Configurations
  # ==========================
  imports = [
    ./hardware-configuration.nix
    ./packages.nix  # Package list in a separate file
  ];

  # ==========================
  # 🔹 Boot Configuration
  # ==========================
  boot.loader.grub = {
    enable = true;
    device = "nodev";  # EFI System
    efiSupport = true;
    efiInstallAsRemovable = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C371-3D17";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # ==========================
  # 🔹 System Settings
  # ==========================
  networking.hostName = "nixos";
  time.timeZone = "Europe/Berlin";

  # ✅ Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # ✅ Enable flakes & new nix commands
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ==========================
  # 🔹 Power Management (Battery Life)
  # ==========================
  services.thermald.enable = true;  # Prevents overheating & throttling
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";  # Optimized for battery life
  hardware.cpu.intel.updateMicrocode = true;  # CPU bug fixes

  # ✅ Enable power-profiles-daemon (REPLACES TLP)
  services.power-profiles-daemon.enable = true;

  # ==========================
  # 🔹 Graphics Optimization
  # ==========================
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver vaapiIntel vaapiVdpau ];

  # ==========================
  # 🔹 Networking & Bluetooth
  # ==========================
  networking.networkmanager.enable = true;

  # ✅ Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Uncomment if you need SSH access
  # services.openssh.enable = true;

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
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # ==========================
  # 🔹 Desktop & UI
  # ==========================
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # ✅ Enable Touchscreen Support
  services.udev.packages = [ pkgs.iptsd ];
  systemd.packages = [ pkgs.iptsd ];

  # ✅ Enable Touchpad Support (if needed)
  # services.xserver.libinput.enable = true;

  # ==========================
  # 🔹 Audio & Media
  # ==========================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ✅ Enable Printing Support
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
      # thunderbird
    ];
  };

  # ✅ Set Zsh as Default Shell
  programs.zsh.enable = true;

  # ✅ Install Firefox
  programs.firefox.enable = true;

  # ==========================
  # 🔹 Security & System Management
  # ==========================
  services.acpid.enable = true;

  # Uncomment if you want to open firewall ports manually
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # ==========================
  # 🔹 System Version (DO NOT CHANGE)
  # ==========================
  system.stateVersion = "24.11"; # Did you read the comment?
}
