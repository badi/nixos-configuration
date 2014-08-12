# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


let

  zfsSnapshotKeepCount = "90";
  zfsSnapshotPools = "tank";

  zfsSnapshotScript = pkgs.writeScript "zfs-snapshot" ''
    ${pkgs.coreutils}/bin/echo "==================================="
    ${pkgs.coreutils}/bin/date
    pool=$1
    keep=$2

    zfs=${pkgs.linuxPackages.zfs}/sbin/zfs
    grep=${pkgs.gnugrep}/bin/grep
    sort=${pkgs.coreutils}/bin/sort
    head=${pkgs.coreutils}/bin/head
    tail=${pkgs.coreutils}/bin/tail
    xargs=${pkgs.findutils}/bin/xargs

    $zfs snapshot -r $pool@$(date +%F-%T)
    $zfs list -t snapshot -o name \
         | $grep tank@ \
	 | $sort -r \
	 | $tail -n +$keep \
	 | $xargs -n 1 $zfs destroy -r
    '';

in

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

    # network tools
    lshw wget

    # editors
    vim  emacs24-nox

    # web
    chromiumWrapper

    # X11

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

     xchat
     irssi

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
  services.cron.enable = true;
  services.cron.systemCronJobs = [

  #    /-------------------- minute
  #    | /------------------ hour
  #    | | /---------------- day of month
  #    | | | /-------------- month
  #    | | | | /------------ day of week
  #    | | | | |
  #    * * * * *

     # every day at 6am
      "* 6 * * * root ${zfsSnapshotScript} ${zfsSnapshotPools} ${zfsSnapshotKeepCount} >>/var/log/zfs-snapshot.log 2>&1"
    ];


}
