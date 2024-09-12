#!/usr/bin/env sh

# Copyright (C) 2019 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

# Given the file, move the files over to the local filesystem instead

# Get the S3 bucket name
S3_BUCKET=$(echo $1 | cut -d'.' -f1)

while read FILE; do
    DIR=$(dirname -- "$FILE")
    if ! [ -d "$DIR" ]; then
        mkdir -p -- "$DIR"
    fi

    if ! [ -s "$FILE" ]; then
        aws s3 cp "s3://$S3_BUCKET/$FILE" "$FILE"
    fi
done < $1