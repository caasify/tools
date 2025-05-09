#!/bin/bash


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


# Version: 1.0.3

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
