# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

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
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 24800 ]; # for synergy
  };


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

    # compression tools
    unzipNLS
    zip

    # nix-related tools
    strategoPackages.strategoxt # pp-aterm for printing .drv files
    nix-repl

    # network tools
    lshw wget

    # network filesystems
    nfsUtils
    cifs_utils

    # editors
    vim  emacs24-nox

    # office work
    libreoffice
    texLiveFull
    biber
    evince
    kde4.gwenview

    # web
    chromiumWrapper
    firefoxWrapper

    # X11
    terminator
    synergy
    feh
    xcompmgr

    # GTK themes
    gtk # for the themes
    gtk-engine-murrine
    gtk_engines
    oxygen_gtk
    lxappearance
    gnome.gnomeicontheme
    hicolor_icon_theme


    # XMonad
    # trayer
    dmenu
    haskellPackages.xmobar

    # misc
     tmux 
     keepassx2
     dropbox
     dropbox-cli
     gitAndTools.gitFull

     xchat
     irssi

  ];

  nixpkgs.config = {

    allowUnfree = true;

    chromium = {
      enableGoogleTalkPlugin = true;
      enablePepperFlash = true; # adobe flash no longer works
      enablePepperPDF = true;
    };

    firefox.enableAdobeFlash = true;
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = with import ./xserverSettings.nix; {
    enable = true;
    videoDrivers = [ "nvidia" ];
    vaapiDrivers = [ pkgs.vaapiVdpau ];
    displayManager.kdm.enable = true;
    desktopManager.kde4.enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };

    # # trying to get multihead with multi gpu to work
    # inherit serverLayoutSection
    #         deviceSection
    #         monitorSection
    #         screenSection
    #         config;

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
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
  };

  time.timeZone = "America/New_York";

  services.cron = import ./cron.nix { inherit pkgs; };

}
