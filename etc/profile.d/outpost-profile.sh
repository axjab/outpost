# Load the user's Bash configuration for login shells.
if [ -r "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
