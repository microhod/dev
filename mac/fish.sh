#! /usr/local/bin/fish
# configuration for the fish shell

echo "install fisher"
curl -s https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish > /dev/null
echo "install pure plugin"
fisher install rafaelrinaldi/pure > /dev/null
echo "install theme"
./theme.fish
