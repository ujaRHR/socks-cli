#!/bin/bash

# Function to start redsocks
start_redsocks() {
  echo "Starting redsocks with configuration..."
  sudo nohup redsocks -c redsocks.conf &
  echo "Redsocks started!"
}

# Function to stop redsocks
stop_redsocks() {
  echo "Stopping redsocks..."
  pkill -f "redsocks"
  echo "Redsocks stopped!"
}

# Function to configure iptables rules
setup_iptables() {
  echo "Setting up iptables rules..."
  sudo iptables -t nat -N REDSOCKS
  sudo iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
  sudo iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
  sudo iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
  sudo iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
  sudo iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
  sudo iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
  sudo iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
  sudo iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN
  sudo iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345
  sudo iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDSOCKS
  sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDSOCKS
  sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDSOCKS
  sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDSOCKS
  echo "Iptables rules set up!"
}

# Function to clear iptables rules
clear_iptables() {
  echo "Clearing iptables rules..."
  sudo iptables -F;
  sudo iptables -t nat -F;
  sudo iptables -t mangle -F;
  sudo iptables -X
  echo "Iptables rules cleared!"
}


# Function to create or modify the redsocks configuration file
create_redsocks_config() {
  echo "Enter SOCKS5 proxy details:"

  read -p "Proxy IP: " proxy_ip
  read -p "Proxy Port: " proxy_port
  read -p "Username (leave blank for none): " proxy_user
  read -p "Password (leave blank for none): " proxy_pass

  cat > ~/redsocks.conf <<EOL
base {
    log_debug = on;
    log_info = on;
    log = "stderr";
    daemon = off;
    redirector = iptables;
}

redsocks {
    local_ip = 127.0.0.1;
    local_port = 12345;
    ip = $proxy_ip;
    port = $proxy_port;
    type = socks5;
    login = "$proxy_user";
    password = "$proxy_pass";
}
EOL

  echo "Configuration saved to ~/redsocks.conf"
}

# CLI to handle user commands
socks5_setup() {
  create_redsocks_config
  start_redsocks
  setup_iptables
  echo "SOCKS5 setup completed!"
  echo "SOCKS5 setup completed!"
}

socks5_connect() {
  echo "Connecting to SOCKS5 proxy..."
  start_redsocks
  setup_iptables
  echo ""
  echo "=_= Connected to SOCKS5 proxy!"
}

socks5_disconnect() {
  echo "Disconnecting from SOCKS5 proxy..."
  stop_redsocks
  clear_iptables
  echo ""
  echo "=_= Disconnected from SOCKS5 proxy!"
}

# Check for arguments
# Routing to appropriate function
case "$1" in
  "setup")
    socks5_setup
    ;;
  "connect")
    socks5_connect
    ;;
  "disconnect")
    socks5_disconnect
    ;;
  *)
    echo "Usage: $0 {setup|connect|disconnect}"
    exit 1
    ;;
esac
