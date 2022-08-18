#!/bin/bash

#ALIASES
echo "" >> ~/.bashrc
echo "#ALIASES" >> ~/.bashrc
echo 'alias full-update="sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y && sudo snap refresh"' >> ~/.bashrc
echo 'alias ll="ls -la"' >> ~/.bashrc
echo 'alias docker-stop-all="sudo docker stop \$(sudo docker ps -aq)"' >> ~/.bashrc
echo 'alias docker-remove-all-containers="sudo docker rm \$(sudo docker ps -aq)"' >> ~/.bashrc
echo 'alias docker-remove-all-images="sudo docker rmi \$(sudo docker images -q)"' >> ~/.bashrc
echo 'alias docker-cleanup="docker-stop-all && docker-remove-all-containers && docker-remove-all-images"' >> ~/.bashrc

sudo apt full-upgrade -y

sudo add-apt-repository -y ppa:papirus/papirus
sudo apt update -y
sudo apt install -y snapd papirus-icon-theme papirus-folders tree gparted curl net-tools python python-pip python3 python3-pip git ssh xclip jq htop openvpn network-manager-openvpn-gnome openvpn-systemd-resolved nodejs npm ghex bless apktool docker.io docker-compose

cd /tmp/

#DOCKER
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker $USER
#DOCKER

#SDKMAN
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 11.0.5-zulu < /dev/null
sdk install kotlin
sdk install gradle
#SDKMAN

#JETBRAINS TOOLBOX
wget https://download-cf.jetbrains.com/toolbox/jetbrains-toolbox-1.15.5387.tar.gz && tar -zxf jetbrains-toolbox-1.15.5387.tar.gz && mkdir ~/.toolbox && cp jetbrains-toolbox-1.15.5387/jetbrains-toolbox ~/.toolbox/ && rm -r jetbrains-toolbox* && ~/.toolbox/jetbrains-toolbox&
#JETBRAINS TOOLBOX

#DEX2JAR
wget https://github.com/pxb1988/dex2jar/releases/download/2.0/dex-tools-2.0.zip && unzip dex-tools-2.0.zip -d ~/ && mv ~/dex2jar-2.0/ ~/dex2jar/ && sudo chmod +x ~/dex2jar/*.sh && rm ~/dex2jar/*.bat && rm dex-tools-2.0.zip
#DEX2JAR

#JADX
git clone git@github.com:skylot/jadx.git && cd jadx && ./gradlew dist && sudo mv /tmp/jadx /opt/ && cd ~/.local/share/applications && echo "[Desktop Entry]" > jadx.desktop && echo "Type=Application" >> jadx.desktop && echo "Name=Jadx" >> jadx.desktop && echo "Icon=/opt/jadx/jadx-gui/src/main/resources/icons-16/jadx-logo.png" >> jadx.desktop && echo "Exec=/opt/jadx/build/jadx/bin/jadx-gui" >> jadx.desktop && echo "Categories=Development;" >> jadx.desktop && cd /tmp/
#JADX

sudo snap install code --classic
sudo snap install postman --channel=candidate
sudo snap install spotify
sudo snap install slack --classic

sudo pip3 install mitmproxy
sudo pip install frida-tools

#CHROME
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo dpkg -i google-chrome-stable_current_amd64.deb && sudo apt install -fy && rm google-chrome-stable_current_amd64.deb
#CHROME
