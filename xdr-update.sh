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
