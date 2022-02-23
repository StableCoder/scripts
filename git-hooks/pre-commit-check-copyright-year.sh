#!/usr/bin/env sh

# When used as a pre-commit hook, this script will check all files that are cached
# to be added to the commit, finds files with copyright/year combinations in the first
# 8 lines, and checks if it matches the current year.
#
# Files that don't have a matching year are listed out and the user is given the option to
# proceed anyway.

# Colours
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NO_COLOUR='\033[0m'

# Variables
FILES=$(git diff --cached --name-only)
YEAR=$(date +%Y)

# Read user input, assign stdin to keyboard
exec < /dev/tty

for FILE in $FILES; do
    # If it's not a file, skip it
    if [ ! -f $FILE ]; then
        continue
    fi

    # Copyright year should always be within the first 5 lines
    head -5 $FILE | grep -i copyright 2>&1 1>/dev/null || continue

    # If the file doesn't have a copyright notice, add it to a list
    if ! grep -i -e "copyright.*$YEAR" $FILE 2>&1 1>/dev/null; then
        MISSING_YEAR_FILES="$MISSING_YEAR_FILES $FILE"
    fi
done

# If there are any files, we'll print them out and ask the user if it's ok to proceed
if [ -n "$MISSING_YEAR_FILES" ]; then
    printf "${YELLOW}>>${NO_COLOUR} $YEAR is missing in the copyright of:\n"
    for FILE in $MISSING_YEAR_FILES; do
        echo "$FILE"
    done
    printf "${CYAN}>>${NO_COLOUR} Do you wish to proceed regardless? [y/N] "
    read -r -p "" RESPONSE
    case "$RESPONSE" in
    [yY][eE][sS] | [yY])
        exit 0
        ;;
    *)
        exit 1
        ;;
    esac
fi
