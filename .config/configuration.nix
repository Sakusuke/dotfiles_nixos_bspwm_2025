{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking and bluetooth
  networking.networkmanager.enable = true;
  networking.hostName = "lap"; # Define your hostname.
  networking.nameservers = [ "192.168.2.50" ];

  # Hosts
  #networking.extraHosts = ''
  #  192.168.2.50 jellyfin.optiplex.box
  #'';

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set your time zone and Locale
  time.timeZone = "Europe/Berlin";
  services.ntp.enable = true;
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

  # WM
  #programs.hyprland.enable = true;
  services.xserver = { 
    enable = true; 
    dpi = 100; 
    windowManager.bspwm.enable = true;
    displayManager = { 
      lightdm.enable = true; 
      lightdm.extraConfig = ''user-authority-in-system-dir=true''; # needed to remove .Xauthority from ~/
      sessionCommands ="${pkgs.sxhkd}/bin/sxhkd &";
    };
  };
  services.displayManager = {
    defaultSession = "none+bspwm"; 
    autoLogin.enable = true; 
    autoLogin.user = "lap"; #BAD 
  };
  ## Compositor
  services.picom.enable = true;
  services.picom.vSync = true;
  ## Graphics
  #hardware.graphics.enable = true;
  hardware.graphics = {
    enable = true;
    # Include necessary Intel graphics packages
    extraPackages = with pkgs; [
      #intel-media-sdk
      vpl-gpu-rt
      mesa # The open-source OpenGL implementation, includes Intel drivers
    ];
  };
  boot.initrd.kernelModules = [ "i915" ];
  
  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  ## fcitx5
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lap = {
    isNormalUser = true;
    description = "Lap";
    extraGroups = [ "networkmanager" "wheel" "samba" "storage" "brigtness" "adbusers" "davfs2" ];
    packages = with pkgs; [];
  };
  users.defaultUserShell = pkgs.zsh;
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "lap";

  # List packages installed in system profile. To search, run:
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    # BSPWM
    sxhkd
    polybar
    rofi
    picom
    nitrogen
    alacritty
    dunst libnotify
    xcape ksuperkey
    xclip clipit
    xorg.xkill
    xdo
    # Graphics
    #libGl
    libglvnd
    mesa

    # other
    vim 
    lf ueberzug bat
    wget
    neofetch
    fd
    sshfs
    trash-cli
    xdg-ninja
    git gh yadm
    firefox
    #google-chrome
    mpv
    picard
    nomacs #for images
    jellyfin-mpv-shim
    jellyfin-media-player
    calibre
    ncdu
    htop
    parsec-bin
    anki
    obsidian
    sioyek
    pamixer pavucontrol
    # WM (Hypr)
    #rofi-wayland
    #waybar hyprpaper
    # file
    pcmanfm
    mate.engrampa
    p7zip
    vimv
    rclone
    wl-clipboard clipman # clipboard util and manager, also WM autostart needed, like tis "wl-paste -t text --watch clipman store" for persistent clipboard
    # Office
    libreoffice-qt
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    # Laptop
    lm_sensors
    brightnessctl
    libsmbios
    # Coding
    vscode
    github-desktop
    ## Python packages
    yt-dlp jq
    ffmpeg
    (python3.withPackages (ps: with ps; [
      ytmusicapi
    ]))
    python313
    python313Packages.pyqt6
    # Rust
    cargo
    rustup
  ];


  # battery services
   services.upower.enable = true;
   services.auto-cpufreq = {
     enable = true;
     settings = {
       battery = {
         governor = "powersave";
         turbo = "never";
       };
       charger = {
         governor = "performance";
         turbo = "auto";
       };
     };
   };

  # List services that you want to enable:
  services.gnome.gnome-keyring.enable = true; # needed for github desktop authentication 
  services.openssh.enable = true;
  security.polkit.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  programs.udevil.enable = true;

  # Virtualization and containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # For binaries like appimage
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      freetype
      harfbuzz
      sqlite
      SDL2
      zstd
    ];
  };

  # Editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };


  # Terminal
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "sudo" ];
      theme = "eastwood";
    };
  };
  ## Terminal Emualtor
  #programs.foot.enable = true; #Wayland
  #programs.alacritty.enable = true;

  # Variables
  environment.sessionVariables = {
    #for xdg-ninja, beware zsh not working/being in the wrong spot
    XDG_DATA_HOME = "$HOME/.local/share"; #these 4 are for general setup for the others
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
    WINEPREFIX = "$XDG_DATA_HOME/wine"; #for .wine
    XINITRC = "$XDG_CONFIG_HOME/X11/xinitrc"; #for .xinitrc
    ZDOTDIR = "$HOME/.config/zsh"; #for zshrc
    #HISTFILE = "$XDG_STATE_HOME/zsh/history"; for some reason this doesnt work, now declaring in .zshrc file
    GNUPGHOME = "$XDG_DATA_HOME/gnupg"; #idk
    GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"; #for .gtkrc
    XCOMPOSECACHE="$XDG_CACHE_HOME/X11/xcompose";
    ERRFILE="$XDG_CACHE_HOME/X11/xsession-errors";
    CARGO_HOME="$XDG_DATA_HOME/cargo";
    RUSTUP_HOME="$XDG_DATA_HOME/rustup";

    ## variables that would usually be .profile, a replacement for that idk what, you have to restart WM for changes to take effect
    QT_SCALE_FACTOR= "1.4";
    ELM_SCALE= "1.4";
    GDK_SCALE= "1.4";
    XCURSOR_SIZE= "30";
  };

  # Fonts
  fonts.packages = with pkgs; [
    #(nerdfonts.override { fonts = [ "Iosevka" ]; })
    nerd-fonts.iosevka
    noto-fonts-cjk-sans
    source-han-sans
    corefonts vistafonts #windows fonts
  ];

  system.stateVersion = "23.11";
}
