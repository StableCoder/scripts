#!/usr/bin/env sh

# Copyright (C) 2019 George Cave.
#
# SPDX-License-Identifier: Apache-2.0

# This is an example of functions that can be used to fill an environment variable for the script,
# which if the variable is required, retries infinitely until it's filled.

RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOUR='\033[0m'

required_var() {
    printf "$1\n"
    printf "Current: $(eval echo \$\{$2\})\n"
    read -r -e response

    case "$response" in
        '')
            if [ "$(eval echo \$\{$2\})" = "" ]; then
                # If not entered, AND the variable is previously empty, re-try until it's non-empty
                printf "$RED >> MUST ENTER A VALUE FOR $2!$NO_COLOUR\n"
                required_var "$1" $2
            fi
            ;;
        *)
            export $2="$response"
            ;;
    esac
}

optional_var() {
    printf "$1\n"
    printf "Current: $(eval echo \$\{$2\})\n"
    read -r -e response
    case "$response" in
        '')
            # Re-use the original value
            export $2=$(eval echo \$\{$2\})
            ;;
        *)
            # Change the value to the response value
            export $2="$response"
            ;;
    esac
}

REQ_VAR=

required_var " $GREEN>> Enter the required variable$NO_COLOUR" REQ_VAR
printf "Required variable: $REQ_VAR\n\n"

optional_var " $GREEN>> Enter the optional variable$NO_COLOUR" OPT_VAR
printf "Optional variable: $OPT_VAR\n"