#!/bin/bash
nohup sh -c 'iptables -A OUTPUT -j DROP && ip6tables -A OUTPUT -j DROP  && sleep 30 && iptables -D OUTPUT -j DROP && ip6tables -D OUTPUT -j DROP' &
