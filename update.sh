#/bin/bash
# Version: 1.0.0

curl -sSfL https://raw.githubusercontent.com/caasify/tools/main/nmap.rules -o /etc/suricata/rules/nmap.rules
chmod 644 /etc/suricata/rules/nmap.rules
sed -i '/#Malware\/trojan oriented rules/a\ - nmap.rules' /etc/suricata/suricata.yaml



curl -sSfL https://raw.githubusercontent.com/caasify/tools/main/block-output.sh -o /var/ossec/active-response/bin/block-output.sh
chmod 744 /var/ossec/active-response/bin/block-output.sh



suricata-update
systemctl restart suricata

systemctl restart wazuh-agent.service
