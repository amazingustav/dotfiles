#!/bin/bash
function isInstalled() {
    if ! command -v $1 &> /dev/null; then
        echo "0"
    else
        echo "1"
    fi
}

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew update
brew tap homebrew/cask
brew tap homebrew/cask-fonts

# DEFAULT
brew install --cask visual-studio-code iterm2 postman spotify slack jetbrains-toolbox docker visualvm authy zoom font-fira-code
brew install zsh zsh-syntax-highlighting tldr xclip tree curl python cmake git grep zip unzip jq htop nodejs npm ghex docker-compose ctop google-chrome awscli k9s subliminal authy ranger

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# DEFAULT

# PYTHON
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py

if [ $(isInstalled pip) == 1 ]; then
    pip install --user pipenv virtualenv awscli localstack-client localstack
fi
# PYTHON

# SDKMAN
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

    sdk list java | ggrep -Po "(8|11|16)(\.\d+)+-zulu" | while read -r JAVA_LATEST_MINOR; do
        sdk install java $JAVA_LATEST_MINOR < /dev/null
    done
    
    sdk install kotlin < /dev/null
fi
# SDKMAN

# NPM
if [ $(isInstalled npm) == 1 ]; then
    npm install -g yarn @nestjs/cli npm@6.14.13 react-native-cli create-react-app create-next-app vercel json-server expo-cli netlify-cli
fi
# NPM

# ZSHELL
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
    mkdir -p ~/.git_dotfiles
    touch ~/.zsh_profile
    
    # DEFAULT
    echo "# OH-MY-ZSH VARS
ZSH_CACHE_DIR=~/.cache/zsh
ZSH_THEME=\"suvash\"
if [ \`tput colors\` != \"256\" ]; then
  ZSH_THEME=\"dstufft\"
fi

export ZSH=\"/Users/$USER/.oh-my-zsh\"

plugins=(autopep8 aws colored-man-pages command-not-found dotenv docker docker-compose man pep8 pip rust rustup sudo golang gradle kubectl mvn sdk spring react-native npm yarn)" > ~/.zshrc

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

# ALIASES
alias ll=\"ls -la\"
alias docker-stop-all=\"docker stop \\\$(docker ps -aq)\"
alias docker-remove-all-containers=\"docker rm -f \\\$(docker ps -aq)\"
alias docker-remove-all-images=\"docker rmi -f \\\$(docker images -q)\"
alias docker-cleanup=\"docker-stop-all && docker-remove-all-containers && docker-remove-all-images\"
alias update-all-repositories='cur_dir=\$(pwd) && for i in \$(find . -name \".git\" 2>/dev/null | ggrep -Po \".*(?=/\.git)\" | grep -v \".*/\..*\"); do cd \"\$cur_dir/\$i\" && echo -e \"\\\n\\\nUPDATING \$i\\\n\\\n\" && git pull || true; done && cd \"\$cur_dir\"'
alias update-all-pip-packages=\"pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U\"
alias update-all-system-packages=\"paru -Syu --noconfirm && flatpak update\"
alias fuck-update-everything='_pwd=\$(pwd) && cd && update-all-system-packages && update-all-pip-packages && rustup update && update-all-repositories && sdk self-update && sdk update && nvm install --lts --reinstall-packages-from=default --latest-npm && npm update -g && cd \"\$_pwd\"'
alias subliminal-pt=\"subliminal download -l pt-BR\"
alias subliminal-en=\"subliminal download -l en\"
alias config=\"git --git-dir=$HOME/.git_dotfiles/ --work-tree=$HOME\"
  
source $ZSH/oh-my-zsh.sh" >> ~/.zshrc

    # SDKMAN
    if [ $(isInstalled sdk) == 1 ]; then
        echo "
# SDKMAN
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR=\"\$HOME/.sdkman\"
[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"" >> ~/.zshrc
    fi
    # SDKMAN
fi
# ZSHELL

    echo "
╔══════════════════════════════════════╗
║          YOUR SETUP IS DONE          ║
╚══════════════════════════════════════╝
 
 1. Make shure no error appeared above;
 2. To use ZSH properly, you have to edit the /etc/shells and remove all shells, except the last one;

"
