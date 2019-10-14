if [ "$version" != "" ]; then
    echo "Using tcsh"
elif [ "$shell" != "" ]; then
    echo "Using $shell"
elif [ "$ZSH_NAME" != "" ]; then
    echo "Using zsh"
elif [ "$BASH" != "" ]; then
    echo "Using bash"
fi