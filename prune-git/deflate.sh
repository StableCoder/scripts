#!/bin/bash

# Number of lines to display for consideration
numLines=10

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n)
    numLines=$2
    shift
    shift
    ;;
esac
done

IFS=$'\n'
objects=`git verify-pack -v .git/objects/pack/pack-*.idx | grep -v chain | sort -k3nr | head -n $numLines`

printf "All sizes are in kB. The pack column is the size of the object, compressed, inside the pack file.\n"
originalSize=$(du -sb . | cut -f1)
originalSize=$(($originalSize / 1024 / 1024))
printf "Total repository size is %iMB\n\n" $originalSize

output="size,pack,SHA,location"
for y in $objects
do
	# extract the size in bytes
	size=$((`echo $y | cut -f 5 -d ' '`/1024))
	# extract the compressed size in bytes
	compressedSize=$((`echo $y | cut -f 6 -d ' '`/1024))
	# extract the SHA
	sha=`echo $y | cut -f 1 -d ' '`
	# find the objects location in the repository tree
	other=`git rev-list --all --objects | grep $sha`
	#lineBreak=`echo -e "\n"`
	output="${output}\n${size},${compressedSize},${other}"
done

echo -e $output | column -t -s ', '

printf "\nEnter the file to remove the history, or leave blank to exit:\n"
read -e removal

if [ "$removal" != "" ]; then
	printf "\nRemoving '$removal' from the repository.\n"
	git filter-branch --tag-name-filter cat --index-filter "git rm -r --cached --ignore-unmatch $removal" --prune-empty -f -- --all

	printf "\nReclaiming space...\n"
	rm -rf .git/refs/original/
	git reflog expire --expire=now --all
	git gc --prune=now
	git gc --aggressive --prune=now

    newSize=$(du -sb . | cut -f1)
    newSize=$(($newSize / 1024 / 1024))
    difference=$(($originalSize - $newSize))

	printf "\n\nDone. Repository went from %iMB to %iMB, representing a decrease of %iMB!\n" $originalSize $newSize $difference
    printf "If you're done, push to the remote via 'git push origin --force --all && git push origin --force --tags'\n\n"
fi