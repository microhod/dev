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
    fi
else
    echo "commit signing already set up with GPG key: ${gpg_id}"
fi

# Credit for git gpg configuration:
# https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65

echo "setting git gpg program to GPG Keychain version"
git config --global gpg.program /usr/local/MacGPG2/bin/gpg2

if [ -z "$(cat ~/.gnupg/gpg-agent.conf | grep 'pinentry-program')" ]
then
    echo "setting ~/.gnupg/gpg-agent.conf pinentry-program"
    echo "pinentry-program /usr/local/MacGPG2/libexec/pinentry-mac.app/Contents/MacOS/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
else
    echo "~/.gnupg/gpg-agent.conf pinentry-program already set"
fi
if [ -z "$(cat ~/.gnupg/gpg.conf | grep 'no-tty')" ]
then
    echo "setting ~/.gnupg/gpg.conf no-tty"
    echo "no-tty" >> ~/.gnupg/gpg.conf
else
    echo "~/.gnupg/gpg.conf no-tty already set"
fi

if [ ! -z "${gpg_id}" ]
then
    echo "run 'gpg --export --armor ${gpg_id}' to export the key for use in github etc"
fi
