#! /bin/bash

# Install homebrew if not installed
if ! command -v brew &> /dev/null
then
    echo "brew not found, installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
fi

echo -e "\n--- homebrew ---\n"

brew bundle --no-lock

echo -e "\n--- terminal ---\n"

echo "install ayu theme"
mkdir -p ~/.config/iterm2-themes
curl -s https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/ayu.itermcolors > ~/.config/iterm2-themes/ayu.itermcolors

echo -e "\n--- fish shell ---\n"
./fish.sh

echo -e "\n--- ssh ---\n"

ssh_keys=$(ls ~/.ssh/id_* 2> /dev/null)
if [ -z "${ssh_keys}" ]
then
    echo "no ssh key found at '~/.ssh/id_*', generating a new pair"
    read -p "Please enter your email address: " email
    read -p "Please choose an algorithm (default: ed25519) " algorithm
    if [ -z "${algorithm}" ]
    then
        algorithm="ed25519"
    fi
    ssh-keygen -t "${algorithm}" -C "${email}"
else
    echo -e "using existing ssh keys:\n${ssh_keys}\n"
fi

if [ ! -f ~/.ssh/config ]
then
    echo "no ssh config found at '~/.ssh/config', generating default config"
    cat <<EOT >> ~/.ssh/config
Host *
    UseKeychain yes
    AddKeysToAgent yes
EOT
else
    echo "using existing ssh config: ~/.ssh/config"
fi

echo -e "\n--- git ---\n"

name=$(git config --global user.name)
if [ -z "${name}" ]
then
    echo "no value for global git name'"
    read -p "Please enter your name: " name
    git config --global user.name "${name}"
else
    echo "using existing global git name: ${name}"
fi

email=$(git config --global user.email)
if [ -z "${email}" ]
then
    echo "no value for global git email"
    read -p "Please enter your email address: " email
    git config --global user.email "${email}"
else
    echo "using existing global git email: ${email}"
fi

echo -e "\n--- gpg ---\n"

gpg_id=$(git config --global user.signingkey)
if [ -z "${gpg_id}" ]
then
    read -p "Do you want to set up GPG commit signing? (y/n) " confirm
    if [ "${confirm}" == "y" ]
    then
        read -p "Pass the ID of the GPG key you want to use (default: generate new key): " gpg_id
        if [ -z "${gpg_id}" ]
        then
            if [ ! -d "/Applications/GPG Keychain.app" ]
            then
                echo "error: GPG Keychain app not found"
                exit 1
            fi
            open "/Applications/GPG Keychain.app"
            read -p "Pass the ID of the newly created key you want to use: " gpg_id
        fi
        if [ -z "${gpg_id}" ]
        then
            echo "error: GPG ID empty"
            exit 1
        fi

        echo "setting global commit signing for GPG key ${gpg_id}"
        git config --global user.signingkey "${gpg_id}"
        echo "enabling commit signing by default"
        git config --global commit.gpgsign true
        echo "setting GPG_TTY variable"
        export GPG_TTY=$(tty)
    fi
else
    echo "commit signing already set up with GPG key: ${gpg_id}"
fi

if [ ! -z "${gpg_id}" ]
then
    echo "run 'gpg --export --armor ${gpg_id}' to export the key for use in github etc"
fi
