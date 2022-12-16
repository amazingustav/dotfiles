#!/bin/bash
function isInstalled() {
    if ! command -v $1 &> /dev/null; then
        echo "0"
    else
        echo "1"
    fi
}

    echo "
╔══════════════════════════════════════╗
║    Which architecture do you have?   ║
╠══════════════════════════════════════╣
║ 1. Apple Silicon (M1 Chip)           ║
║ 2. Intel Chip                        ║
╚══════════════════════════════════════╝
"
    read -p "Option: " MENU_OPTION

    if [ "$MENU_OPTION" == "1" ]; then
      KUBECTL_URL = "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
      BREW_PATH = "/opt/homebrew/bin/brew"
    elif [ "$MENU_OPTION" == "2" ]; then
      KUBECTL_URL = "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
      BREW_PATH = "/usr/local/bin/brew"
    else
      break
    fi

clear
echo "
╔══════════════════════════════════════╗
║     INSTALLING PRE-REQUIREMENTS      ║
╚══════════════════════════════════════╝
"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$($BREW_PATH shellenv)"

###########
# DEFAULT #
###########
brew update
brew tap homebrew/cask
brew tap homebrew/cask-fonts

brew install --cask spotify slack authy zoom font-fira-code
brew install zsh zsh-syntax-highlighting google-chrome tldr xclip tree git grep htop ghex subliminal ranger

# DEV TOOLS
brew tap dbcli/tap
brew install --cask visual-studio-code postman jetbrains-toolbox docker visualvm
brew install asdf pgcli python cmake git jq node npm ctop awscli k9s

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

curl -L0 $KUBECTL_URL

##################
# DOCKER-COMPOSE #
##################
clear
echo "
╔══════════════════════════════════════╗
║     CONFIGURING DOCKER AND PYTHON    ║
╚══════════════════════════════════════╝
"
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose

##########
# PYTHON #
##########
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py

if [ $(isInstalled pip) == 1 ]; then
    pip install --user pipenv virtualenv awscli localstack-client localstack
fi

##########
# SDKMAN #
##########
clear
echo "
╔══════════════════════════════════════╗
║      CONFIGURING SDKMAN AND ZSH      ║
╚══════════════════════════════════════╝
"
if [ $(isInstalled zsh) == 1 ] && [ $(isInstalled sdk) == 0 ]; then
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

    sdk list java | ggrep -Po "(16)(\.\d+)+-adoptopenjdk" | while read -r JAVA_LATEST_MINOR; do
        sdk install java $JAVA_LATEST_MINOR < /dev/null
    done

    sdk install kotlin < /dev/null
fi

#######
# NPM #
#######
if [ $(isInstalled npm) == 1 ]; then
    npm install -g yarn @nestjs/cli npm@6.14.13 react-native-cli vercel json-server expo-cli netlify-cli
fi

##########
# ZSHELL #
##########
if [ $(isInstalled zsh) == 1 ]; then
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        echo $(which zsh) | sudo tee -a /etc/shells

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
    echo "##################
# OH-MY-ZSH VARS #
##################
ZSH_CACHE_DIR=~/.cache/zsh
ZSH_THEME=\"cloud\" #suvash
if [ \`tput colors\` != \"256\" ]; then
  ZSH_THEME=\"dstufft\"
fi
export ZSH=\"$HOME/.oh-my-zsh\"
plugins=(autopep8 aws colored-man-pages command-not-found dotenv docker docker-compose man pep8 pip rust sudo golang gradle kubectl mvn sdk spring react-native npm yarn)" > ~/.zshrc

    echo -n "
# PYTHON VARS
PIPENV_VENV_IN_PROJECT=true
# FUNCTIONS
kill-on-port() {
    pid=\"\$(lsof -t -i:\$1)\"
    if [ -n \"\$pid\" ]; then
        kill -9 \$pid;
    fi
}

###########
# ALIASES #
###########
alias ll=\"ls -la\"
alias docker-stop-all=\"docker stop \$(docker ps -aq)\"
alias docker-remove-all-containers=\"docker rm -f \$(docker ps -aq)\"
alias docker-remove-all-images=\"docker rmi -f \$(docker images -q)\"
alias docker-remove-all-volumes=\"DOCKER_BUILDKIT=1 docker builder prune --all --force\"
alias docker-cleanup=\"docker-stop-all && docker-remove-all-containers && docker-remove-all-images && docker-remove-all-volumes\"
alias update-all-pip-packages=\"pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U\"
alias subliminal-pt=\"subliminal download -l pt-BR\"
alias subliminal-en=\"subliminal download -l en\"
alias config=\"git --git-dir=$HOME/.git_dotfiles/ --work-tree=$HOME\"
alias python=\"python3\"
alias android-emulator=\"$HOME/Library/Android/sdk/emulator/emulator -avd Pixel_3a_Android_Q &\"

############
# ENV VARS #
############
export ERL_AFLAGS=\"-kernel shell_history enabled -kernel shell_history_fil_bytes 1024000\"
export ERL_FLAGS=\"$ERL_FLAGS +S 24:24\"
export KERL_CONFIGURE_OPTIONS=\"--disable-debug --without-javac --without-wx\"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=\"$HOME/development/peek/peek-stack/bin:$PATH\"
export PATH=\"$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH\"
export PATH=\"/opt/homebrew/opt/libpq/bin:$PATH\"
export PATH=\"$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH\"

. /usr/local/opt/asdf/libexec/asdf.sh
source $ZSH/oh-my-zsh.sh" >> ~/.zshrc

if [ $(isInstalled sdk) == 1 ]; then
    echo "
##########
# SDKMAN #
##########
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR=\"\$HOME/.sdkman\"
[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"" >> ~/.zshrc
fi

source $HOME/.zshrc

################
# ASDF PLUGINS #
################
clear
echo "
╔══════════════════════════════════════╗
║           CONFIGURING ASDF           ║
╚══════════════════════════════════════╝
"
export KERL_BUILD_DOCS=yes

asdf plugin add erlang
asdf plugin add elixir
asdf install erlang 25.1.2
asdf install elixir 1.14.1

clear
echo "
╔══════════════════════════════════════╗
║          YOUR SETUP IS DONE          ║
╚══════════════════════════════════════╝
 1. Make shure no error appeared above;
 2. To use ZSH properly, you have to edit the /etc/shells and remove all shells, except the last one;
"
