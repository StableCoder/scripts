#!/usr/bin/env bash

# Copyright (C) 2018-2019 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master`; do
    git branch --track ${branch##*/} $branch
done