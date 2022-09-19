#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

mkdir -p /etc/ansible
wget -P /etc/ansible http://$PACKER_HTTP_ADDR/exam/customers.json
wget -P /etc/ansible http://$PACKER_HTTP_ADDR/exam/hosts
wget -P /etc/ansible http://$PACKER_HTTP_ADDR/exam/users.csv

apt-get install -y jq
wget -nv -O /tmp/vscode.tar.gz https://update.code.visualstudio.com/latest/server-linux-x64/stable
su - appadmin -c 'mkdir -p /home/appadmin/.vscode-server/bin'
su - appadmin -c 'tar -xzf /tmp/vscode.tar.gz -C /home/appadmin/.vscode-server/bin'
su - appadmin -c 'mv /home/appadmin/.vscode-server/bin/vscode-server-linux-x64  /home/appadmin/.vscode-server/bin/$(cat /home/appadmin/.vscode-server/bin/vscode-server-linux-x64/product.json | jq -j .commit)'
su - appadmin -c '/home/appadmin/.vscode-server/bin/*/bin/code-server --install-extension ms-python.python --force'
su - appadmin -c '/home/appadmin/.vscode-server/bin/*/bin/code-server --install-extension redhat.ansible --force'