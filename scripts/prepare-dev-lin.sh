#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

# Install Gnome
apt-get install -y task-gnome-desktop
systemctl set-default graphical.target

# Install OpenVM tools for Desktop
apt-get install -y open-vm-tools-desktop

# Install zealdocs
wget -nv -O /tmp/zeal.deb http://deb.debian.org/debian/pool/main/z/zeal/zeal_0.6.1-1.2~bpo11+1_amd64.deb
apt-get install -y /tmp/zeal.deb
# Create Desktop Shortcut for Zealdocs
su - appadmin -c 'mkdir -p /home/appadmin/.local/share/applications'
su - appadmin -c 'cat >/home/appadmin/.local/share/applications/Zeal.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Zeal Docs
Icon=/usr/share/icons/hicolor/32x32/apps/zeal.png
Exec=/usr/bin/zeal
Comment=Offline Documentation Browser
Categories=Development;
Terminal=false
EOF'

# Install temporarily zeal-cli
wget -nv -P /tmp https://github.com/Morpheus636/zeal-cli/releases/download/v1.1.0/zeal-cli
chmod +x /tmp/zeal-cli
su - appadmin -c 'mkdir -p /home/appadmin/.local/share/Zeal/Zeal/docsets'

# Download docsets
su - appadmin -c '/tmp/zeal-cli install Python_3 Ansible Jinja Flask Django'
wget -nv -O /tmp/cisco-yangmodal.tar.gz "https://drive.switch.ch/index.php/s/QLto1t9DH076F49/download"
su - appadmin -c 'tar -xzf /tmp/cisco-yangmodal.tar.gz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'

# Install VSCode
apt install -y gpg
wget -nv -O /tmp/vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
apt-get install -y /tmp/vscode.deb
su - appadmin -c '/usr/bin/code --install-extension ms-vscode-remote.remote-ssh --force'
su - appadmin -c '/usr/bin/code --install-extension ms-python.python --force'
su - appadmin -c '/usr/bin/code --install-extension redhat.ansible --force'

# Install Pycharm Community
version=2022.2.1
wget -nv -O /tmp/pycharm.tar.gz https://download.jetbrains.com/python/pycharm-community-${version}.tar.gz
tar -xzf /tmp/pycharm.tar.gz -C /opt
mv /opt/pycharm* /opt/pycharm
ln -s "/opt/pycharm/bin/pycharm.sh" /usr/bin/pycharm

# Create Desktop Shortcut for Pycharm
su - appadmin -c 'cat >/home/appadmin/.local/share/applications/Pycharm.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Icon=/opt/pycharm/bin/pycharm.png
Exec=/usr/bin/pycharm
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm-ce
StartupNotify=true
EOF'

# Install Postman
wget -nv -O /tmp/postman.tar.gz "https://dl.pstmn.io/download/latest/linux64"
tar -xzf /tmp/postman.tar.gz -C /opt
ln -s /opt/Postman/Postman /usr/bin/postman
su - appadmin -c "mkdir -p /home/appadmin/.local/share/applications"

# Create Desktop Shortcut for Postman
su - appadmin -c 'cat >/home/appadmin/.local/share/applications/Postman.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=/opt/Postman/app/Postman %U
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOF'