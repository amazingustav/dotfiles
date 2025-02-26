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
║ 1. Apple Silicon                     ║
║ 2. Intel Chip                        ║
╚══════════════════════════════════════╝
"
    read -p "Option: " MENU_OPTION

    if [ "$MENU_OPTION" == "1" ]; then
      KUBECTL_URL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
      BREW_PATH="/opt/homebrew/bin/brew"
    elif [ "$MENU_OPTION" == "2" ]; then
      KUBECTL_URL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
      BREW_PATH="/usr/local/bin/brew"
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

brew install --cask font-jetbrains-mono-nerd-font
brew install zsh zsh-syntax-highlighting tldr xclip tree git grep htop ghex ranger

###################
## OPTIONAL TOOLS #
###################
brew install --cask slack zoom plex-media-server elmedia-player ytmdesktop-youtube-music discord monitorcontrol rectangle notion balenaetcher logi-options+ steam

# APP STORE TOOLS
brew install mas # Mac App Store CLI
mas install 1510445899 # Meeter
mas install 1561788435 # Usage
mas install 1339001002 # Record It

#############
# DEV TOOLS #
#############
brew install --cask visual-studio-code jetbrains-toolbox orbstack bruno warp raycast
brew install asdf pgcli pyenv cmake git jq ctop awscli k9s

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -L0 $KUBECTL_URL

clear
echo "
╔══════════════════════════════════════╗
║     CONFIGURING DOCKER AND PYTHON    ║
╚══════════════════════════════════════╝
"
# DOCKER-COMPOSE
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose

# PYTHON
pyenv install 3.13.1 && pyenv global 3.13.1

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
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

if [ $(isInstalled sdk) == 1 ]; then
    sdk selfupdate force

    sed -i '' '/auto_answer/s/false/true/' ~/.sdkman/etc/config > /dev/null 2>&1
    sed -i '' '/auto_selfupdate/s/false/true/' ~/.sdkman/etc/config > /dev/null 2>&1
    sed -i '' '/colour_enable/s/false/true/' ~/.sdkman/etc/config > /dev/null 2>&1
    sed -i '' '/auto_env/s/false/true/' ~/.sdkman/etc/config > /dev/null 2>&1

    sdk list java | ggrep -Po "(21)(\.\d+)+-amzn" | while read -r JAVA_LATEST_MINOR; do
        sdk install java $JAVA_LATEST_MINOR < /dev/null
        break
    done

    sdk install kotlin < /dev/null
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
fi

    # DEFAULT
    echo "##################
# OH-MY-ZSH VARS #
##################
ZSH_CACHE_DIR=~/.cache/zsh
ZSH_THEME='avit'
if [ \`tput colors\` != \"256\" ]; then
  ZSH_THEME='dstufft'
fi
export ZSH=\"$HOME/.oh-my-zsh\"
plugins=(autopep8 pep8 git aws colored-man-pages command-not-found dotenv docker docker-compose man pip rust sudo golang gradle kubectl mvn sdk spring react-native npm yarn)" > ~/.zshrc

    echo -n "
##########
# PYTHON #
##########
export PYENV_ROOT=\"$HOME/.pyenv\"
[[ -d $PYENV_ROOT/bin ]] && export PATH=\"$PYENV_ROOT/bin:$PATH\"
eval \$(pyenv init -)
eval \$(pyenv virtualenv-init -)

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
alias k9s-prod=\"kubectl config use-context prod && k9s\"
alias k9s-dev=\"kubectl config use-context dev && k9s\"
alias gtm=\"git co . && git co main && git fetch -p && git pull\"

############
# ENV VARS #
############
export KERL_CONFIGURE_OPTIONS=\"--disable-debug --without-javac --without-wx\"
export ANDROID_HOME=\"$HOME/Library/Android/sdk\"
export PATH=\"/usr/local/bin:$PATH\"
export PATH=\"$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH\"
export PATH=\"/opt/homebrew/opt/libpq/bin:$PATH\"
export PATH=\"$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH\"
export PATH=\"/opt/homebrew/opt/postgresql@15/bin:$PATH\"
export PATH=\"$HOME/bin:$PATH\"

. /usr/local/opt/asdf/libexec/asdf.sh
source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

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

clear
echo "
╔══════════════════════════════════════╗
║          YOUR SETUP IS DONE          ║
╚══════════════════════════════════════╝
 1. Make shure no error appeared above;
 2. To use ZSH properly, you have to edit the /etc/shells and remove all shells, except the last one;
"
