#!/usr/bin/env sh

if [ -f ~/.profile ]; then
    echo "Found .profile [Read at login]"
fi

# bash
if [ -f ~/.bash_profile ]; then
    echo "Found .bash_profile [Read at login]"
fi
if [ -f ~/.bashrc ]; then
    echo "Found .bashrc [Read when interactive]"
fi
if [ -f ~/.bash_login ]; then
    echo "Found .bash_login [Read at login]"
fi
if [ -f ~/.bash_logout ]; then
    echo "Found .bash_logout [Read at login]"
fi

# zsh
if [ -f ~/.zshenv ]; then
    echo "Found .zshenv [Read every time]"
fi
if [ -f ~/.zprofile ]; then
    echo "Found .zprofile [Read at login]"
fi
if [ -f ~/.zshrc ]; then
    echo "Found .zshrc [Read when interactive]"
fi
if [ -f ~/.zlogin ]; then
    echo "Found .zlogin [Read at login]"
fi
if [ -f ~/.zlogout ]; then
    echo "Found .zlogout [Read at logout][Within login shell]"
fi