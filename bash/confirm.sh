#!/bin/bash

printf "Example bash script of using a confirmation dialog\n"

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

confirm "This is an example, check the script for the how. [y/N]" && printf "You confirmed.\n"