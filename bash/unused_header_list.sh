#!/usr/bin/env sh

# It is assumed all '.d' files found have just dependency information

# Colours
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NO_COLOUR='\033[0m'

# Variables
ROOT_SEARCH_PATH=$(pwd)
FILE_TYPES="\.h$ \.hpp$"

# Determine the absolute directory path of the file
absolute_path() {
    pushd $(dirname -- $1) &>/dev/null
    echo $(pwd)/$(basename -- $1)
    popd &>/dev/null
}

# Determine the set of 'used' headers, using each file found which ends with '.d'
USED_HEADERS=
for FILE in $(find -- "$ROOT_SEARCH_PATH" | grep -e "\.d$"); do
    printf "${GREEN}Processing$NO_COLOUR: $(absolute_path $FILE)\n"

    # For each dependency, other than the first line itself, get that file's absolute path
    for ITEM in $(tail -n +2 $FILE); do
        # Skip plain '\' items
        if [ "$ITEM" == '\' ]; then
            continue
        fi

        ABS_PATH=$(absolute_path $ITEM)

        # Filter out paths not wanted
        if ! grep -e "$ROOT_SEARCH_PATH" <<<$ABS_PATH &>/dev/null; then
            continue
        fi

        # Filter out undesired file types
        FILTERED=1
        for FILTER in $FILE_TYPES; do
            if grep -e "$FILTER" <<<$ABS_PATH &>/dev/null; then
                FILTERED=0
            fi
        done

        if [[ $FILTERED -ne 0 ]]; then
            continue
        fi

        # If it's not in the USED_HEADERS list, add it
        if ! grep -w -- $ABS_PATH <<<$USED_HEADERS &>/dev/null; then
            printf "  ${CYAN}Added$NO_COLOUR: $ABS_PATH\n"
            USED_HEADERS="$USED_HEADERS $ABS_PATH"
        fi
    done
done

# Now, using the set of 'used' headers, go through all the headers in the same root search path and
# determine the set that exist but aren't used.
echo "${YELLOW}Unused files$NO_COLOUR:"
for FILE in $(find $ROOT_SEARCH_PATH); do
    ABS_PATH=$(absolute_path $FILE)

    # Filter out undesired file types
    FILTERED=1
    for FILTER in $FILE_TYPES; do
        if grep -e "$FILTER" <<<$ABS_PATH &>/dev/null; then
            FILTERED=0
        fi
    done

    if [[ $FILTERED -ne 0 ]]; then
        continue
    fi

    if ! grep -w -- $ABS_PATH <<<$USED_HEADERS &>/dev/null; then
        printf "  $FILE\n"
    fi
done
