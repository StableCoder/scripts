#!/usr/bin/env bash

# Copyright (C) 2019 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

# These are a small subset of the available colours:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
# For the full set, go here https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOUR='\033[0m'

printf "printf ${RED}RED\n"
printf "printf ${NO_COLOUR} reset\n\n"

echo -e "echo ${GREEN}GREEN"
echo -e "echo ${NO_COLOUR} reset"