# Pruning a Git repository

Most often, especially in enterprise organizations, there are committals of binary or other large files that really shouldn't be in a repo, Visual Studio binary blob files, database dumps, binary library dependencies. This can be mitigated by going through and purging problematic files from a repository's whole history.

##### Beware!

Doing this could possibly rewrite the entire git history, requiring others with local repositories to rebase or reclone the repository! Be sure that now is a good time!

## Setup

First, clone the repostory to a location, then run the `setup.sh` script, which will go through and pull down all branches fully, including all of the histories. This will allow for a thorough purging of files from the repository.

## Deflation

Running `deflate.sh` will display the top set of space-consuming files in the git history, and will ask for a file to remove. Repeat as necessary until the repository is cleaned and/or shrunk as desired.

## Force Push

Running `force-push.sh` or running the below commands will forcefully push the entire tree/history to the origin remote. Beware that, as changing the history, this will invalidate any checkouts already in the wild, and that others will have to re-clone or `git rebase`.

```sh
git push origin --force --all
git push origin --force --tags
```