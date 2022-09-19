#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

# Configure root password
echo "root:$WSC_ROOT_PWD" | chpasswd

# Configure appadmin password
echo "appadmin:$WSC_ADMIN_PWD" | chpasswd

# Disable package repositories
rm -f /etc/apt/sources.list.d/*
cat >/etc/apt/sources.list <<'EOF'
# No package repositories available
EOF
apt-cdrom add