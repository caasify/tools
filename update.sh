#/bin/bash
# Version: 1.0.2

# Detect package system
if [ -f /etc/apt/sources.list ]; then
  package_system="deb"
elif [ -d /etc/yum.repos.d/ ]; then
  package_system="rpm"
fi

# Install ufw
if [[ $package_system == "deb" ]]; then
  apt install ufw -y

elif [[ $package_system == "rpm" ]]; then
  yum install ufw -y
fi

# Allow UFW income
ufw default allow incoming

# Add ufw rules
ufw deny out from any to 200.0.0.0/8
ufw deny out from any to 102.0.0.0/8
ufw deny out from any to 10.0.0.0/8
ufw deny out from any to 100.64.0.0/10
ufw deny out from any to 169.254.0.0/16
ufw deny out from any to 198.18.0.0/15
ufw deny out from any to 198.51.100.0/24
ufw deny out from any to 203.0.113.0/24
ufw deny out from any to 224.0.0.0/4
ufw deny out from any to 240.0.0.0/4
ufw deny out from any to 255.255.255.255/32
ufw deny out from any to 192.0.0.0/24
ufw deny out from any to 192.0.2.0/24
ufw deny out from any to 127.0.0.0/8
ufw deny out from any to 192.168.0.0/16
ufw deny out from any to 0.0.0.0/8
ufw deny out from any to 172.16.0.0/12
ufw deny out from any to 224.0.0.0/3
ufw deny out from any to 192.88.99.0/24
ufw deny out from any to 198.18.140.0/24
ufw deny out from any to 102.230.9.0/24
ufw deny out from any to 102.233.71.0/24

# Enable UFW
ufw --force enable
