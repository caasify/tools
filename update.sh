#/bin/bash
# Version: 1.0.1

#!/bin/bash

# Detect package system
if [ -f /etc/apt/sources.list ]; then
  apt install auditd audispd-plugins -y
elif [ -d /etc/yum.repos.d/ ]; then
  yum install audit audispd-plugins -y
fi

sudo bash -c 'echo "<ossec_config>
<localfile>
  <log_format>audit</log_format>
  <location>/var/log/audit/audit.log</location>
</localfile>
</ossec_config>" >> /var/ossec/etc/ossec.conf'


echo "-a exit,always -F euid=0 -F arch=b64 -S execve -k audit-wazuh-c" >> /etc/audit/rules.d/audit.rules
echo "-a exit,always -F euid=0 -F arch=b32 -S execve -k audit-wazuh-c" >> /etc/audit/rules.d/audit.rules

service auditd restart
service wazuh-agent restart
