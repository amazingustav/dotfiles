source /etc/zsh/zprofile
source /home/gustavo/.zshenv

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
#if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#  source /usr/share/zsh/manjaro-zsh-prompt
#fi

# ZSH
ZSH_CACHE_DIR=~/.cache/zsh
#ZSH_THEME="agnoster"
ZSH_THEME="suvash"
#ZSH_THEME="kardan"

plugins=(adb autopep8 aws cargo colored-man-pages command-not-found django docker-compose docker flutter git golang gradle heroku jfrog kubectl man minikube node npm pep8 pip redis-cli rust rustup scala sdk spring sudo terraform themes yarn colorize)

source ~/.oh-my-zsh/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# PYTHON
PIPENV_VENV_IN_PROJECT=true

#ALIASES
alias ll="ls -la"

alias docker-stop-all="docker stop \$(docker ps -aq)"
alias docker-remove-all-containers="docker rm -f \$(docker ps -aq)"
alias docker-remove-all-images="docker rmi -f \$(docker images -q)"
alias docker-cleanup="docker-stop-all && docker-remove-all-containers && docker-remove-all-images"

alias update-all-repositories='cur_dir=$(pwd) && for i in $(find . -name ".git" 2>/dev/null | grep -Po ".*(?=/\.git)" | grep -v ".*/\..*"); do cd "$cur_dir/$i" && echo -e "\\n\\nUPDATING $i\\n\\n" && git pull || true; done && cd "$cur_dir"'
alias update-all-pip-packages="pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U"
alias update-all-system-packages="yay -Syu --noconfirm && sudo pacman -Syyu --noconfirm && flatpak update"
alias update-everything='_pwd=$(pwd) && cd && update-all-system-packages && update-all-pip-packages && rustup update && update-all-repositories && sdk self-update && sdk update && nvm install --lts --reinstall-packages-from=default --latest-npm && npm update -g && cd "$_pwd"'

alias subliminal-pt='subliminal download -l pt-BR'
alias subliminal-en='subliminal download -l en'

alias config='/usr/bin/git --git-dir=/home/gustavo/.cfg/ --work-tree=/home/gustavo'

