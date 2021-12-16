#!/bin/bash
clear
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\033[1;31mScript need to be run as root!\033[0m"; exit 1
fi

apt-get -qq update
apt-get -y -qq install squid

alamat_ip=$(wget -qO- ipv4.icanhazip.com)

echo "acl localnet src 0.0.0.1-0.255.255.255
acl localnet src 10.0.0.0/8
acl localnet src 100.64.0.0/10
acl localnet src 169.254.0.0/16
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localnet src fc00::/7
acl localnet src fe80::/10

acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl cybertize dst $alamat_ip/24

http_access allow cybertize
http_access allow localnet
http_access allow localhost
http_access allow manager localhost
http_access deny manager
http_access deny all
http_port 3128
http_port 8888
http_port 8000

cache deny all
access_log none
cache_store_log none
cache_log /dev/null
hierarchy_stoplist cgi-bin ?

refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname www.squid-cache.org" > /etc/squid/squid.conf

systemctl restart squid
