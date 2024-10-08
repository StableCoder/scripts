#!/usr/bin/env sh

# Copyright (C) 2019-2023 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

# Installing Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Dev Tools
brew install git-lfs cmake ninja
git lfs install

# Libraries
brew install bullet glfw assimp glm portaudio freeimage yaml-cpp fmt

# VulkanSDK
curl -O https://sdk.lunarg.com/sdk/download/latest/mac/vulkan-sdk.dmg
open vulkan-sdk.dmg
sleep 10
cd /Volumes/vulkansdk-macos-*
./install-vulkan.py
cd ..
rm -rf vulkan*
