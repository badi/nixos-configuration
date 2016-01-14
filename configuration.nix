# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  nix.binaryCaches = [
    https://cache.nixos.org/
    http://hydra.cryp.to
  ];

  nix.trustedBinaryCaches = [
    https://cache.nixos.org/
    http://hydra.cryp.to
  ];

  boot.supportedFilesystems = [ "zfs" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostId = "f125f099";
  networking.hostName = "fangorn"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 24800 ]; # for synergy
  };

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "enp2s9";



  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };


  # List packages installed in system profile. To search by name, run:
  # -env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # system tools
    file
    lsof
    psmisc
    which
    hwdata
    iotop

    # network tools
    lshw wget

    # network filesystems
    nfsUtils
    cifs_utils

    # editors
    vim  emacs24-nox

    # misc
     tmux 
     gitAndTools.gitFull

    xscreensaver

  ];

  nixpkgs.config.allowUnfree = true;

  # List services that you want to enable:
  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
  services.printing.enable = true;

  services.udev.extraRules = ''
    # Yubico u2f rules
    # https://github.com/Yubico/libu2f-host/blob/master/70-u2f.rules
    # this udev file should be used with udev 188 and newer

    # this udev file should be used with udev 188 and newer
    ACTION!="add|change", GOTO="u2f_end"

    # Yubico YubiKey
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"

    # Happlink (formaly Plug-Up) Security KEY
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="f1d0", TAG+="uaccess"

    #  Neowave Keydo and Keydo AES
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1e0d", ATTRS{idProduct}=="f1d0|f1ae", TAG+="uaccess"

    # HyperSecu HyperFIDO
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", ATTRS{idProduct}=="0880", TAG+="uaccess"

    LABEL="u2f_end"

  '';

  # Enable the X11 windowing system.
  services.xserver = with import ./xserverSettings.nix; {
    enable = true;
    videoDrivers = [ "nvidia" ];
    vaapiDrivers = [ pkgs.vaapiVdpau ];
    displayManager.kdm.enable = true;
    desktopManager.kde4.enable = true;
    desktopManager.xfce.enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  hardware.opengl.driSupport32Bit = true;

  # access to fonts
  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      inconsolata
      liberation_ttf
      terminus_font
      ttf_bitstream_vera
      vistafonts
    ];
  };



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.badi = {
    createHome = true;
    home = "/home/badi";
    group = "users";
    extraGroups = [ "wheel" "networkmanager" "docker" "vboxusers" ];
    shell = "/run/current-system/sw/bin/zsh";
  };

  time.timeZone = "America/New_York";

  services.cron = import ./cron.nix { inherit pkgs; };

  virtualisation.docker.enable = true;

  system.autoUpgrade.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.bluetooth.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
      bluez = pkgs.bluez5;
  };

}
