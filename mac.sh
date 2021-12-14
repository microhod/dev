#! /bin/bash

# Install homebrew if not installed
if ! command -v brew &> /dev/null
then
    echo "brew not found, installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
fi

echo -e "\n--- terminal ---\n"

echo "install iterm2"
brew install iterm2 > /dev/null
echo "install ayu theme"
mkdir -p ~/.config/iterm2-themes
curl -s https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/ayu.itermcolors > ~/.config/iterm2-themes/ayu.itermcolors

echo "install fish"
brew install fish > /dev/null
echo "install fisher"
curl -s https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish > /dev/null
echo "install pure plugin"
fish -c fisher install rafaelrinaldi/pure > /dev/null
echo "install ayu theme"
fish -c fisher install edouard-lopez/ayu-theme.fish > /dev/null

echo -e "\n--- dev tools ---\n"

echo "install vscode"
brew install --cask visual-studio-code > /dev/null
echo "install golang"
brew install go
echo "install postman"
brew install --cask postman

echo -e "\n--- ssh ---\n"

if ! ls ~/.ssh/id_* 1> /dev/null 2>&1
then
    echo "no ssh key found, generating a new pair"
    read -p "Please enter your email address: " email
    read -p "Please choose an algorithm (default: ed25519) " algorithm
    if [ -z "${algorithm}" ]
    then
        algorithm="ed25519"
    fi
    ssh-keygen -t "${algorithm}" -C "${email}"
fi

if ! ls ~/.ssh/config 1> /dev/null 2>&1
then
    echo "no ssh config found, generating default config"
    cat <<EOT >> ~/.ssh/config
Host *
    UseKeychain yes
    AddKeysToAgent yes
EOT
fi

echo -e "\n--- git ---\n"

if [ -z "$(git config --global user.name)" ]
then
    echo "no value for 'git config --global user.name'"
    read -p "Please enter your name: " name
    git config --global user.name "${name}"
fi

if [ -z "$(git config --global user.email)" ]
then
    echo "no value for 'git config --global user.email'"
    read -p "Please enter your email address: " email
    git config --global user.email "${email}"
fi
