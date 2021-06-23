#!/bin/bash
function isInstalled() {
    if ! command -v $1 &> /dev/null; then
        echo "0"
    else
        echo "1"
    fi
}

sudo pacman-mirrors --geoip && sudo pacman -Syyu
sudo pacman -Syuq --needed --noconfirm --noprogressbar base-devel cmake git rustup

# RUSTUP
if [ $(isInstalled rustup) == 1 ]; then
    rustup install stable
    rustup default stable
    rustup component add rls
fi
# RUSTUP

# PARU
if [ $(isInstalled paru) == 0 ]; then
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
fi
# PARU

# DEFAULT
paru -Syuq --needed --sudoloop --noconfirm --noprogressbar posix-user-portability pacman-contrib zsh zsh-syntax-highlighting ttf-jetbrains-mono ttf-fira-code ttf-nerd-fonts-symbols-mono noto-fonts-emoji gst-libav man xclip tree curl net-tools networkmanager-openvpn zip unzip jq yq htop python python-pip docker-compose ctop libvirt google-chrome ttf-ms-fonts oh-my-zsh-git visual-studio-code-bin postman-bin k9s android-sdk jdk8-openjdk subliminal
# DEFAULT

# PYTHON
if [ $(isInstalled pip) == 1 ]; then
    # DEFAULT
    pip install --user pipenv virtualenv awscli
    # DEFAULT

    # BACKEND
    if [ "$BACKEND" == "1" ]; then
        pip install --user localstack-client localstack
    fi
    # BACKEND

    # DATA-SCIENCE
    if [ "$DATA_SCIENCE" == "1" ]; then
        pip install --user notebook
    fi
    # DATA-SCIENCE
fi
# PYTHON

# SDKMAN
if [ "$BACKEND" == "1" ] && [ $(isInstalled zsh) == 1 ] && [ $(isInstalled sdk) == 0 ]; then
    curl -s "https://get.sdkman.io" | zsh
fi

SDKMAN_INIT_FILE="$HOME/.sdkman/bin/sdkman-init.sh"
if [ -f "$SDKMAN_INIT_FILE" ]; then
    source "$SDKMAN_INIT_FILE"
fi

if [ $(isInstalled sdk) == 1 ]; then
    sdk selfupdate force

    sed -i '/auto_answer/s/false/true/' ~/.sdkman/etc/config
    sed -i '/auto_selfupdate/s/false/true/' ~/.sdkman/etc/config
    sed -i '/colour_enable/s/false/true/' ~/.sdkman/etc/config
    sed -i '/auto_env/s/false/true/' ~/.sdkman/etc/config

    sdk list java | grep -Po "(8|11|16)(\.\d+)+-zulu" | while read -r JAVA_LATEST_MINOR; do
        sdk install java $JAVA_LATEST_MINOR < /dev/null
    done
    
    sdk install kotlin < /dev/null
    sdk install visualvm < /dev/null

    # VISUALVM
echo "[Desktop Entry]
Name=VisualVM
Type=Application
Categories=Development;
Exec=$HOME/.sdkman/candidates/visualvm/current/bin/visualvm
Icon=$HOME/.sdkman/candidates/visualvm/current/etc/visualvm.icns
" > ~/.local/share/applications/visualvm-sdkman.desktop
    # VISUALVM
fi
# SDKMAN

# NPM
if [ $(isInstalled npm) == 1 ]; then
    npm install -g yarn @nestjs/cli react-native-cli create-react-app create-next-app vercel json-server expo-cli netlify-cli

fi
# NPM

# ANDROID-SDK
    mkdir -p ~/.android && touch ~/.android/repositories.cfg

    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
    export ANDROID_HOME=/opt/android-sdk
    export ANDROID_SDK_ROOT=/opt/android-sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/tools
    export PATH=$PATH:$ANDROID_HOME/tools/bin
    export PATH=$PATH:$ANDROID_HOME/platform-tools

	sudo chown $USER:$USER $ANDROID_HOME -R

    sdkmanager --update
    yes | sdkmanager --install platform-tools emulator
    yes | sdkmanager --licenses

    SDKMANAGER_LIST=$(sdkmanager --list)
    SDKMANAGER_PLATFORMS=$(echo $SDKMANAGER_LIST | grep -Po "platforms;android-(\d{2,}|[a-zA-Z]*)" | sort -r | head -1)
    SDKMANAGER_BUILD_TOOLS=$(echo $SDKMANAGER_LIST | grep -Po "build-tools;(\d+\.){2}\d+(?=\s)" | sort -r | head -1)
    SDKMANAGER_SYSTEM_IMAGES=$(echo $SDKMANAGER_LIST | grep -Po "system-images;android\S*google_apis;x86_64" | sort -r | head -1)

    sdkmanager "$SDKMANAGER_PLATFORMS"
    sdkmanager "$SDKMANAGER_BUILD_TOOLS"
    sdkmanager "$SDKMANAGER_SYSTEM_IMAGES"
    avdmanager create avd --force --name pixel --device "pixel_xl" --package "$SDKMANAGER_SYSTEM_IMAGES"
fi
# ANDROID-SDK

# KVM
sudo usermod -aG kvm $USER
# KVM

# DOCKER
if [ $(isInstalled docker) == 1 ]; then
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
fi
# DOCKER

# ZSHELL
if [ $(isInstalled zsh) == 1 ]; then
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        while : ; do
            chsh -s $(which zsh)
            [[ "$?" == "1" ]] || break
        done
        while : ; do
            sudo chsh -s $(which zsh)
            [[ "$?" == "1" ]] || break
        done
    fi
    mkdir -p ~/.cache/zsh
    touch ~/.zsh_profile
    
    # DEFAULT
    echo "# OH-MY-ZSH VARS
ZSH_CACHE_DIR=~/.cache/zsh
ZSH_THEME=\"agnoster\"
if [ \`tput colors\` != \"256\" ]; then
  ZSH_THEME=\"dstufft\"
fi
plugins=(autopep8 aws colored-man-pages command-not-found dotenv docker docker-compose man pep8 pip rust rustup sudo golang gradle kubectl mvn sdk spring react-native npm yarn " > ~/.zshrc

    echo -n ")
# PYTHON VARS
PIPENV_VENV_IN_PROJECT=true
# FUNCTIONS
kill-on-port() {
    pid=\"\$(lsof -t -i:\$1)\"
    if [ -n \"\$pid\" ]; then
        kill -9 \$pid;
    fi
}
# ALIASES
alias ll=\"ls -la\"
alias docker-stop-all=\"docker stop \\\$(docker ps -aq)\"
alias docker-remove-all-containers=\"docker rm -f \\\$(docker ps -aq)\"
alias docker-remove-all-images=\"docker rmi -f \\\$(docker images -q)\"
alias docker-cleanup=\"docker-stop-all && docker-remove-all-containers && docker-remove-all-images\"
alias update-all-repositories='cur_dir=\$(pwd) && for i in \$(find . -name \".git\" 2>/dev/null | grep -Po \".*(?=/\.git)\" | grep -v \".*/\..*\"); do cd \"\$cur_dir/\$i\" && echo -e \"\\\n\\\nUPDATING \$i\\\n\\\n\" && git pull || true; done && cd \"\$cur_dir\"'
alias update-all-pip-packages=\"pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U\"
alias update-all-system-packages=\"paru -Syu --noconfirm && flatpak update\"
alias fuck-update-everything='_pwd=\$(pwd) && cd && update-all-system-packages && update-all-pip-packages && rustup update && update-all-repositories && sdk self-update && sdk update && nvm install --lts --reinstall-packages-from=default --latest-npm && npm update -g " >> ~/.zshrc
  
    echo "&& cd \"\$_pwd\"'
# USER PROFILE SOURCE
# ADD YOUR CUSTOM VARIABLES, ALIAS AND THEMES IN THE FILE BELOW
source \"\$HOME/.zsh_profile\"
# OH-MY-ZSH SOURCE
source /usr/share/oh-my-zsh/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

    # SDKMAN
    if [ $(isInstalled sdk) == 1 ]; then
        echo "
# SDKMAN
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR=\"\$HOME/.sdkman\"
[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"" >> ~/.zshrc
    fi
    # SDKMAN

    # ANDROID-SDK
    if [ "$FRONTEND" == "1" ]; then
        echo "
# ANDROID-SDK
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=\$PATH:$ANDROID_HOME/emulator
export PATH=\$PATH:$ANDROID_HOME/tools
export PATH=\$PATH:$ANDROID_HOME/tools/bin
export PATH=\$PATH:$ANDROID_HOME/platform-tools
" >> ~/.zshrc
    fi
    # ANDROID-SDK

    sudo cp ~/.zshrc /root/
    sudo touch ~/.zsh_profile
fi
# ZSHELL
