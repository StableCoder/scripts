#!/usr/bin/env sh

set -e

# Goes through an S3 bucket, and lists *all* files.

# Print the whole directory readout to a file
aws s3 ls s3://$1 > $1.raw_dir

# Print the second column, the actual directory name
awk '{$1=""; print $0}' $1.raw_dir | awk '{$1=$1;print}' > $1.dir

# Clean the output file
printf "" > $1.files

# Print the 4th column and beyond, the filenames themselves
while read LINE; do
    aws s3 ls s3://$1/$LINE | awk '{$1=$2=$3=""; print $0}' | awk '{$1=$1;print}' > $1.dir_files

    while read FILE; do
        printf '%s\n' "$LINE$FILE" >> $1.files
    done < $1.dir_files
done < $1.dir