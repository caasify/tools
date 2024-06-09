#!/bin/bash

dc_type=$1
vm_name=$2

export WAZUH_MANAGER="xdr.caasify.com"
export WAZUH_AGENT_GROUP="$dc_type,Suricata"
export WAZUH_AGENT_NAME="$vm_name"

# Detect package system
if [ -f /etc/apt/sources.list ]; then
  package_system="deb"
elif [ -d /etc/yum.repos.d/ ]; then
  package_system="rpm"
fi

# Detect CPU architecture
arch=$(uname -m)
if [[ $arch == aarch64* ]]; then
  cpu_arch="aarch64"
elif [[ $arch == x86_64* ]]; then
  cpu_arch="amd64"
fi


# install wazuh-agent
if [[ $package_system == "deb" ]]; then
  if [[ $cpu_arch == "amd64" ]]; then
  package='amd64.deb'
  elif [[ $cpu_arch == "aarch64" ]]; then
  package='arm64.deb'
  fi
  add-apt-repository ppa:oisf/suricata-stable
  apt-get update
  apt-get install suricata tar wget -y
  wget -O /tmp/wazuh.deb "https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.3-1_$package" 
  dpkg -i /tmp/wazuh.deb

elif [[ $package_system == "rpm" ]]; then

  if [[ $cpu_arch == "aarch64" ]]; then
    package='aarch64.rpm'
  elif [[ $cpu_arch == "amd64" ]]; then
    package='x86_64.rpm'
  fi
  dnf install epel-release dnf-plugins-core -y
  dnf copr enable @oisf/suricata-7.0 -y
  dnf install suricata wget tar -y
  wget -O /tmp/wazuh.rpm "https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.3-1.$package"
  rpm -ihv /tmp/wazuh.rpm
fi

cd /tmp/ && wget https://rules.emergingthreats.net/open/suricata-6.0.3/emerging.rules.tar.gz
tar xvzf /tmp/emerging.rules.tar.gz
rm -rf /etc/suricata/rules 
mkdir /etc/suricata/rules
chmod 755 /etc/suricata/rules/
mv /tmp/rules/*.rules /etc/suricata/rules/
chmod 644 /etc/suricata/rules/*.rules



rm -f /etc/suricata/suricata.yaml
wget -O /etc/suricata/suricata.yaml https://packages.wazuh.com/4.3/suricata.yml
interface=$(ip route | grep default | awk '{print $5}')
myip=$(curl https://ipinfo.io/ip)
sed -i 's/eth0/'"$interface"'/g' /etc/suricata/suricata.yaml
sed -i.bak 's/HOME_NET: "\[192.168.0.0\/16,10.0.0.0\/8,172.16.0.0\/12\]"/HOME_NET: "'"$myip"'"/' /etc/suricata/suricata.yaml


suricata-update

systemctl daemon-reload
systemctl enable suricata 
systemctl enable wazuh-agent
systemctl start suricata 
systemctl start wazuh-agent
systemctl restart suricata

sudo mkdir -p /opt/xdr-update
sudo chown $USER:$USER /opt/xdr-update

cat << 'EOF' > /opt/xdr-update/xdr-update.sh
#!/bin/bash
URL="https://raw.githubusercontent.com/caasify/tools/main/update.sh"
SCRIPT_PATH="/opt/xdr-update/update.sh"
VERSION_FILE="/opt/xdr-update/version"

curl -sSfL "$URL" -o "$SCRIPT_PATH"
NEW_VERSION=$(grep '^# Version:' $SCRIPT_PATH | awk '{print $3}')
OLD_VERSION=$(cat $VERSION_FILE)

if [ "$NEW_VERSION" != "$OLD_VERSION" ]; then
    echo $NEW_VERSION > $VERSION_FILE
    bash $SCRIPT_PATH
    rm $SCRIPT_PATH
else
    rm $SCRIPT_PATH
fi
EOF

chmod +x /opt/xdr-update/xdr-update.sh

cat <<'EOF' >  /etc/systemd/system/xdr-update.service
[Unit]
Description=xdr-update

[Service]
Type=oneshot
ExecStart=/opt/xdr-update/xdr-update.sh

[Install]
WantedBy=multi-user.target
EOF


cat <<'EOF' > /etc/systemd/system/xdr-update.timer
[Unit]
Description=xdr-update

[Timer]
OnCalendar=hourly
Persistent=true
Unit=xdr-update.service

[Install]
WantedBy=timers.target
EOF


systemctl daemon-reload
systemctl enable xdr-update.timer
systemctl start xdr-update.timer
