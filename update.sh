#/bin/bash
# Version: 1.0.0

curl -sSfL https://raw.githubusercontent.com/aleksibovellan/opnsense-suricata-nmaps/main/local.rules -o /etc/suricata/rules/nmap.rules
chmod 644 /etc/suricata/rules/nmap.rules
sed -i '/#Malware\/trojan oriented rules/a\ - nmap.rules' /etc/suricata/suricata.yaml



curl -sSfL https://raw.githubusercontent.com/alireza-pmahdavi/tools2/main/active-response.tar.gz -o /var/ossec/active-response/bin/active-response.tar.gz
tar xvzf /var/ossec/active-response/bin/active-response.tar.gz -C /var/ossec/active-response/bin/
chmod 744 /var/ossec/active-response/bin/block-*
rm -rf /var/ossec/active-response/bin/active-response.tar.gz



suricata-update
systemctl restart suricata

systemctl restart wazuh-agent.service
