#!/usr/bin/env sh

# Installing Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Dev Tools
brew install git-lfs cmake ninja
git lfs install

# Vulkan
curl -O https://sdk.lunarg.com/sdk/download/latest/mac/vulkan-sdk.tar.gz
cd vulkansdk-macos-*
./install-vulkan.py
cd ..
rm -rf vulkan*
