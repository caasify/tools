#/bin/bash
# Version: 1.0.4

cat <<EOF > /etc/rcnul.local
#!/bin/bash
ip route add blackhole 200.0.0.0/8
ip route add blackhole 102.0.0.0/8
ip route add blackhole 10.0.0.0/8
ip route add blackhole 100.64.0.0/10
ip route add blackhole 169.254.0.0/16
ip route add blackhole 198.18.0.0/15
ip route add blackhole 198.51.100.0/24
ip route add blackhole 203.0.113.0/24
ip route add blackhole 224.0.0.0/4
ip route add blackhole 240.0.0.0/4
ip route add blackhole 255.255.255.255/32
ip route add blackhole 192.0.0.0/24
ip route add blackhole 192.0.2.0/24
ip route add blackhole 127.0.0.0/8
ip route add blackhole 192.168.0.0/16
ip route add blackhole 0.0.0.0/8
ip route add blackhole 172.16.0.0/12
ip route add blackhole 224.0.0.0/3
ip route add blackhole 192.88.99.0/24
ip route add blackhole 198.18.140.0/24
ip route add blackhole 102.230.9.0/24
ip route add blackhole 102.233.71.0/24
EOF

chmod +x /etc/rcnul.local

cat <<EOB > /etc/systemd/system/rcnul-local.service
[Unit]
Description=/etc/rcnul.local Compatibility
After=network.target

[Service]
ExecStart=/etc/rcnul.local
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOB

systemctl daemon-reload
systemctl enable rcnul-local
systemctl start rcnul-local
