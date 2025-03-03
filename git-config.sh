#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'
GIT_PATH=$(which git)
XCLIP_PATH=$(which xclip)

if ! command -v git &> /dev/null || ! command -v xclip &> /dev/null; then
    echo "${RED}Oops! You need to install git and xclip before running this script!${NO_COLOR}"
    exit 1
fi

while :
do
    clear
    echo "
╔══════════════════════════════════════╗
║        Welcome to git-config         ║
╠══════════════════════════════════════╣
║ 0. Exit [DEFAULT]                    ║
║ 1. Configure global user             ║
║ 2. Configure user in a custom folder ║
║ 3. Generate SSH                      ║
╚══════════════════════════════════════╝
"
    read -p "Option: " MENU_OPTION

    if [ "$MENU_OPTION" == "1" ]; then
        GIT_NAME=$(git config --global user.name)
        GIT_EMAIL=$(git config --global user.email)
        GIT_OVERWRITE=1

        if [ -n "$GIT_NAME" ] || [ -n "$GIT_EMAIL" ]; then
            clear
            echo -e "${YELLOW}
╔══════════════════════════════════════════╗
║                 WARNING                  ║
╠══════════════════════════════════════════╣
║ You have already set up your global user ║
╚══════════════════════════════════════════╝
${NO_COLOR}
User name : $GIT_NAME
User email: $GIT_EMAIL
"
            read -p "Do you want to overwrite it? [y/N]: " GIT_OVERWRITE_INPUT

            if [ "$GIT_OVERWRITE_INPUT" == "y" ] || [ "$GIT_OVERWRITE_INPUT" == "Y" ]; then
                GIT_OVERWRITE=1
            else
                GIT_OVERWRITE=0
            fi
        fi

        if [ "$GIT_OVERWRITE" == "1" ]; then
            clear
            echo -e "${YELLOW}
╔════════════════════════════════════╗
║ You're setting up your global user ║
╚════════════════════════════════════╝${NO_COLOR}
"
            read -p "Type your full name: " GIT_NAME
            read -p "Type your e-mail: " GIT_EMAIL

            git config --global user.name "$GIT_NAME"
            git config --global user.email "$GIT_EMAIL"
            git config --global pull.rebase true
            git config --global push.default current
            git config --global init.defaultBranch main
            git config --global core.editor nano
            git config --global alias.ci commit
            git config --global alias.co checkout
            git config --global alias.cb "checkout -b"
            git config --global alias.br branch
            git config --global alias.st status
            git config --global alias.sf "show --name-only"
            git config --global alias.lg "log --pretty=format:'%Cred%h%Creset %C(bold)%cr%Creset %Cgreen<%an>%Creset %s' --max-count=30"
            git config --global alias.incoming "!(git fetch --quiet && git log --pretty=format:'%C(yellow)%h %C(white)- %C(red)%an %C(white)- %C(cyan)%d%Creset %s %C(white)- %ar%Creset' ..@{u})"
            git config --global alias.outgoing "!(git fetch --quiet && git log --pretty=format:'%C(yellow)%h %C(white)- %C(red)%an %C(white)- %C(cyan)%d%Creset %s %C(white)- %ar%Creset' @{u}..)"
            git config --global alias.unstage "reset HEAD --"
            git config --global alias.undo "checkout --"
            git config --global alias.rollback "reset --soft HEAD~1"  
        fi
    elif [ "$MENU_OPTION" == "2" ]; then
        DIRECTORY=~/

        while :
        do
        clear
            echo -e "Please select a directory:\n"

            select DIRECTORY in "$DIRECTORY"*/;
            do
                test -n "$DIRECTORY" && break
            done

            read -p "Do you want to select another directory inside $DIRECTORY [Y/n]?: " INSIDE_DIRECTORY

            if [ "$INSIDE_DIRECTORY" == "n" ] || [ "$INSIDE_DIRECTORY" == "N" ]; then
                break
            fi
        done

        GIT_NAME=$(git config --file $DIRECTORY/.gitconfig user.name)
        GIT_EMAIL=$(git config --file $DIRECTORY/.gitconfig user.email)
        GIT_OVERWRITE=1

        if [ -n "$GIT_NAME" ] || [ -n "$GIT_EMAIL" ]; then
            clear
            echo -e "${YELLOW}
╔════════════════════════════════════════╗
║                 WARNING                ║
╠════════════════════════════════════════╣
║ You have already set up this directory ║
╚════════════════════════════════════════╝
${NO_COLOR}
User name : $GIT_NAME
User email: $GIT_EMAIL
"
            read -p "Do you want to overwrite it? [y/N]: " GIT_OVERWRITE_INPUT

            if [ "$GIT_OVERWRITE_INPUT" == "y" ] || [ "$GIT_OVERWRITE_INPUT" == "Y" ]; then
                GIT_OVERWRITE=1
            else
                GIT_OVERWRITE=0
            fi
        fi

        if [ "$GIT_OVERWRITE" == "1" ]; then
            clear
            echo "
╔══════════════════════════════════════╗
║ You're setting up your local user at ║
  $DIRECTORY
╚══════════════════════════════════════╝
"
            read -p "Type your full name: " GIT_NAME
            read -p "Type your e-mail: " GIT_EMAIL

            git config --file $DIRECTORY/.gitconfig user.name "$GIT_NAME"
            git config --file $DIRECTORY/.gitconfig user.email "$GIT_EMAIL"
            git config --file $DIRECTORY/.gitconfig pull.rebase true
            git config --file $DIRECTORY/.gitconfig init.defaultBranch main
            git config --global --add includeif.gitdir:$DIRECTORY.path $DIRECTORY.gitconfig
            clear
            echo -e "${GREEN}
╔════════════════════════════════════╗
║    User configured successfully!   ║
╠════════════════════════════════════╣
║    Press any key to continue...    ║
╚════════════════════════════════════╝${NO_COLOR}"
            read
        fi
    elif [ "$MENU_OPTION" == "3" ]; then
        while :
        do
            clear
            echo "
╔══════════════════════════════════════╗
║     Select a product to configure    ║
╠══════════════════════════════════════╣
║ 0. Cancel                            ║
║ 1. Github [DEFAULT]                  ║
║ 2. Bitbucket                         ║
║ 3. Gitlab                            ║
║ 4. Other                             ║
╚══════════════════════════════════════╝
"
            read -p "Option: " VCS_OPTION

            GIT_EMAIL=$(git config --global user.email)
            VCS_NAME=github
            VCS_SSH_URL="https://github.com/settings/keys"

            if [ "$VCS_OPTION" == "0" ]; then
                break
            elif [ -z "$VCS_OPTION" ] || [ "$VCS_OPTION" == "1" ]; then
                VCS_NAME=github
                VCS_SSH_URL="https://github.com/settings/keys"
            elif [ "$VCS_OPTION" == "2" ]; then
                VCS_NAME=bitbucket
                VCS_SSH_URL="https://bitbucket.org/account/settings/ssh-keys/"
            elif [ "$VCS_OPTION" == "3" ]; then
                VCS_NAME=gitlab
                VCS_SSH_URL="https://gitlab.com/profile/keys"
            else
                read -p "Type the service name: " VCS_OTHER_NAME
                
                VCS_NAME=$(echo "$VCS_OTHER_NAME" | awk '{print tolower($0)}')
            fi

            ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f ~/.ssh/id_rsa_$VCS_NAME -q -N ""
            ssh-add ~/.ssh/id_rsa_$VCS_NAME
            touch ~/.ssh/config
            eval "$(ssh-agent -s)"
cat >> ~/.ssh/config <<EOF
Host $VCS_NAME.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa_$VCS_NAME
EOF

            clear

            echo -e "${GREEN}
╔══════════════════════════════════════════════╗
║         Your SSH key is on clipboard         ║
╠══════════════════════════════════════════════╣
║   Copy your SSH key below and paste on the   ║
║  website that is shown                       ║
╚══════════════════════════════════════════════╝${NO_COLOR}\n\n"
            
            cat $HOME/.ssh/id_rsa_$VCS_NAME.pub
            
            echo "\n\nURL: $VCS_SSH_URL"
            
            read -p "\n\nDo you want to configure another SSH key? [y/N]: " CONTINUE_OPTION

            if [ "$CONTINUE_OPTION" != "y" ] && [ "$CONTINUE_OPTION" != "Y" ]; then
                break
            fi
        done
    else
        break
    fi
done
