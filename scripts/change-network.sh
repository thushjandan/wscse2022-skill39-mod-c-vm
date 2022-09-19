#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

# Disable predictable network interface names
sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub
update-grub

# Deploy network interface configuration
cat >/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
   address $WSC_IP
   netmask 255.255.255.0
EOF
