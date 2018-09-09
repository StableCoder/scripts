#!/bin/bash

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --help)
    echo "This script allows for easier use of mass encrypted drives. It reads"
    echo "from a file given by -f <name> and has items within paired per-line as"
    echo "'<blkid> <mount point>', but still asks for the passphrase instead of"
    echo "looking for a file."
    exit 0
    ;;
esac
done

# Read the input file for block IDs and mapping locations.
read -ep "Enter the file to read block/mount information from: " INPUT_FILE
if [ "$INPUT_FILE" != "" ]; then
    i=0
    while read line
    do
        IN_FILEARR[$i]="$line"
        i=$((i+1))
    done < $INPUT_FILE
else
    echo "No file specified."
    exit 0
fi

# Read in `blkid` info
i=0
while read line
do
    IN_BLKARR[$i]="$line"
    i=$((i+1))
done< <(blkid)

# Process/compare and mount.
for blkid_line in "${IN_BLKARR[@]}"
do
    for file_line in "${IN_FILEARR[@]}"
    do
        file_blkid=$( echo $file_line | cut -d " " -f 1)
        file_mnt=$( echo $file_line | cut -d " " -f 2)
        blkid_dev=$( echo $blkid_line | cut -d ":" -f 1)
        # Search for the file line that has a matching block ID
        if [[ $blkid_line == *$file_blkid* && ! $(ls /dev/mapper/$file_blkid) ]]
        then
            echo "Found matching blkid for $file_blkid, with target of $file_mnt"
            cryptsetup open $blkid_dev $file_blkid
            mkdir -p $file_mnt
            mount /dev/mapper/$file_blkid $file_mnt
        fi
    done
done