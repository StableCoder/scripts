# `confirm.sh`

Example bash script of using a confirmation dialog.

# `equals-command-args-example.sh`

An example of a bash script that takes in multi-part command line arguments that uses an equals, such as `-f=<string>`.

# `space-command-args-example.sh`

An example of a bash script that takes in multi-part command line arguments that uses an equals, such as `-f <string>`.

# `mount_encrypted_drives.sh`

This script allows for easier use of mass encrypted drives. It reads from a file given by -f <FILENAME> and has items within paired per-line as `<blkid> <fs mount point>`, but still asks for the passphrase instead of looking for a file.

# Useful script pieces

This succeeds if something is at the mount location:
```sh
if mount | grep /mnt/point > /dev/null; then
fi
```