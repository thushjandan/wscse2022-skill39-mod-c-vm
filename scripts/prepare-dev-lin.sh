#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

# Install Gnome
apt-get install -y task-gnome-desktop
systemctl set-default graphical.target

# Install OpenVM tools for Desktop
apt-get install -y open-vm-tools-desktop gpg

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
wget -nv -O /tmp/cisco-yangmodal.tar.gz "https://drive.switch.ch/index.php/s/QLto1t9DH076F49/download"
su - appadmin -c 'tar -xzf /tmp/cisco-yangmodal.tar.gz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'
wget -nv -O /tmp/Ansible.tgz 'https://kapeli.com/feeds/zzz/versions/Ansible/2.10.8/Ansible.tgz'
su - appadmin -c 'tar -xzf /tmp/Ansible.tgz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'
wget -nv -O /tmp/Python_3.tgz 'https://kapeli.com/feeds/zzz/versions/Python_3/3.9.2/Python_3.tgz'
su - appadmin -c 'tar -xzf /tmp/Python_3.tgz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'
wget -nv -O /tmp/Flask.tgz 'https://kapeli.com/feeds/zzz/versions/Flask/1.1.2/Flask.tgz'
su - appadmin -c 'tar -xzf /tmp/Flask.tgz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'
wget -nv -O /tmp/Jinja.tgz 'https://kapeli.com/feeds/zzz/versions/Jinja/2.11.3/Jinja.tgz'
su - appadmin -c 'tar -xzf /tmp/Jinja.tgz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'
wget -nv -O /tmp/Django.tgz 'https://kapeli.com/feeds/zzz/versions/Django/2.2.7/Django.tgz'
su - appadmin -c 'tar -xzf /tmp/Django.tgz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'
wget -nv -O /tmp/FastAPI.tar.gz 'https://drive.switch.ch/index.php/s/c7LBpfVoR6w6iIn/download'
su - appadmin -c 'tar -xzf /tmp/FastAPI.tar.gz -C /home/appadmin/.local/share/Zeal/Zeal/docsets'

# Install VSCode
wget -nv -O /tmp/vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
apt-get install -y /tmp/vscode.deb
su - appadmin -c '/usr/bin/code --install-extension ms-vscode-remote.remote-ssh --force'
su - appadmin -c '/usr/bin/code --install-extension ms-python.python --force'
su - appadmin -c '/usr/bin/code --install-extension redhat.ansible --force'

# Install Pycharm Community
version=2022.2.2
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

# Download Postman collection for TP
wget -nv -P /root http://$PACKER_HTTP_ADDR/WSCSE2022_Module_C_API.postman_collection.json
cp /root/WSCSE2022_Module_C_API.postman_collection.json /home/appadmin/WSCSE2022_Module_C_API.postman_collection.json
chown appadmin:appadmin /home/appadmin/WSCSE2022_Module_C_API.postman_collection.json