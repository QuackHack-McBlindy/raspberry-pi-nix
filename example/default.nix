{ pkgs, lib, ... }: 
let 
  import pubkey = ./../pubkeys.nix
  user = "pungkula";
in
{

  services.locate.enable = true;
  time.timeZone = "Europe/Stockholm";
  i18n = {
     # defaultLocale = "sv_SE.UTF-8";
      defaultLocale = "en_US.UTF-8";
      # consoleFont   = "lat9w-16";
      consoleKeyMap = "sv-latin1";
      extraLocaleSettings = {
          LC_ADDRESS = "sv_SE.UTF-8";
          LC_IDENTIFICATION = "sv_SE.UTF-8";
          LC_MEASUREMENT = "sv_SE.UTF-8";
          LC_MONETARY = "sv_SE.UTF-8";
          LC_NAME = "sv_SE.UTF-8";
          LC_NUMERIC = "sv_SE.UTF-8";
          LC_PAPER = "sv_SE.UTF-8";
          LC_TELEPHONE = "sv_SE.UTF-8";
          LC_TIME = "sv_SE.UTF-8";
      };
  };

  users.users.root.initialPassword = "root";
   
  users."${user}" = {
    hashedPassword = "$y$j9T$m8hPD36i1VMaO5rurbZ4j0$KpzQyat.F6NoWFKpisEj77TvpN2wBGB8ezd26QoKDj6";
    isNormalUser = true;
    description = "${user}";
    group = "${user}";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };
  networking = {
    hostName = "pi";
    useDHCP = false;
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };
  raspberry-pi-nix.board = "bcm2711";
  hardware = {
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            BOOT_UART = {
              value = 1;
              enable = true;
            };
            uart_2ndstage = {
              value = 1;
              enable = true;
            };
          };
          dt-overlays = {
            disable-bt = {
              enable = true;
              params = { };
            };
          };
        };
      };
    };
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.${user}.openssh.authorizedKeys.keys = [ 
      pubkey.desktop
      pubkey.laptop
  ];

  services.openssh = {
      enable = true;
      ports = [ 22 ];
      openFirewall = true;   
      knownHosts = {
          desktop.publicKey = pubkey.desktop;
          laptop.publicKey = pubkey.laptop;
          nasty.publicKey = pubkey.nasty;
          # homie.publicKey = pubkey.homie;
      };

      settings = {    
          AllowUsers = [ user ];  
          PasswordAuthentication = true;
          PermitRootLogin = "no"; 
          MaxAuthTries = "3";  
          # UsePAM = "yes"; 

          # DisableForwarding = false; 
          # PermitEmptyPasswords = false;  
          # ClientAliveInterval = 60;  # Server sends keep-alive messages every 60 seconds
          # ClientAliveCountMax = 3;  # Disconnect clients after 3 missed keep-alives

          # Specify which algorithms to use
          # Ciphers = "aes128-ctr,aes192-ctr,aes256-ctr";
          # MACs = "hmac-sha2-256,hmac-sha2-512";
          # KexAlgorithms = "curve25519-sha256@libssh.org,diffie-hellman-group14-sha1";
            
          LogLevel = "VERBOSE";
      };
  };
  
}
