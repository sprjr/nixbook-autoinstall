{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix>
  ];

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Include necessary packages
  environment.systemPackages = with pkgs; [
    git
    vim  # Optional: include editor for convenience
    wget
    curl
  ];

  # Automatically fetch and prepare your installation scripts
  system.activationScripts.setupInstallationTools = {
    text = ''
      # Create a setup script that will be available after booting the live ISO
      mkdir -p /etc/nixos/setup
      cat > /etc/nixos/setup/autoinstall.sh << 'EOF'
#!/bin/sh
# Script to automate your installation process
echo "Starting automated setup..."

# 1. Ensure network is connected (might need manual intervention)
echo "Please ensure network connection is available."
echo "If you need to connect to WiFi, use 'sudo nmcli device wifi connect SSID password PASSWORD', or 'nmtui' for a guided process"

# 2. Clone the repository
cd /etc/
sudo git clone https://github.com/mkellyxp/nixbook
cd nixbook

# 3. Run installation script
sudo ./install.sh

echo "Setup completed!"
EOF
      chmod +x /etc/nixos/setup/autoinstall.sh

      # Create a README to guide the user
      cat > /etc/nixos/setup/README.txt << 'EOF'
NixOS Custom Installation

This ISO includes an automated setup script that will:
1. Clone the repository from https://github.com/mkellyxp/nixbook
2. Run the install.sh script from that repository

To start the automated installation:
1. Boot from this ISO
2. Ensure you have a network connection (ethernet is easiest, but if only Wi-Fi is available just run `nmtui`)
3. Run: sudo /etc/nixos/setup/autoinstall.sh

Note: This ISO was configured with 'allowUnfree = true' and without a desktop environment.
EOF
    '';
    deps = [];
  };

  # You could also add a systemd service to automatically show instructions at boot
  systemd.services.auto-install = {
    description = "Automatic installation";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/nixos/setup/autoinstall.sh";
    };
  };
}
