# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  nixpkgs.config.allowUnfree = true;

  boot.supportedFilesystems = [ "zfs" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "fangorn"; # Define your hostname.

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
    which
    zfstools

    # network tools
    lshw wget

    # editors
    vim  emacs24-nox

    # web
    chromiumWrapper

    # X11
    xlibs.libXinerama
    xlibs.xineramaproto

    # XMonad
    # trayer
    dmenu
    haskellPackages.xmobar
    xlibs.libXinerama

    # misc
     tmux 
     keepassx2
     dropbox
     dropbox-cli
     gitAndTools.gitFull

  ];

  nixpkgs.config.chromium.enableAdobeFlash = true;


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;


  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.kdm.enable = true;
    desktopManager.kde4.enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.badi = {
    createHome = true;
    home = "/home/badi";
    group = "users";
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
  };

  time.timeZone = "America/New_York";


  # define cronjobs
  # /-------------------- minute
  # | /------------------ hour
  # | | /---------------- day of month
  # | | | /-------------- month
  # | | | | /------------ day of week
  # | | | | |
  # * * * * *

  # services.cron.systemCronJobs = [
  #   ""


}
