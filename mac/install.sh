#!/usr/bin/env sh

# Installing Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Dev Tools
brew install git-lfs cmake ninja
git lfs install

# Conan
pip3 install conan