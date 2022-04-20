# dotfiles

## Install dotfiles from this repo

Clone this repo with all of its submodules, and update the submodules to their latest version:
```
git clone --recurse-submodules --remote-submodules --jobs 8 git@github.com:alex-ortan/dotfiles.git

git submodule sync
git submodule update --init --recursive --remote --merge --jobs 8
git pull --recurse-submodules
```

Create a `.secrets` file where you define all the variables needed to fill in the `.template` files. Here's an example, but modify the values as needed:
```
DWD="/home/alex/MyFavoriteDirectory"
GITHUB_NAME="alex-ortan"
GITHUB_EMAIL="aortan@umn.edu"
GITHUB_OLD_URL="https://github.com"
GITHUB_NEW_URL='"https://github.com"'
GITHUB_PROXY=""
etc
```

Install dotfiles with bashdot.
```
env $(cat .secrets | xargs)  bashdot/bashdot install default
```

This command is idempotent - meaning in particular that you can rerun it without side effects.


## Github

In some cases, say if you commit to both a work and personal github account, you'll want to change the name/email you use for a specific repository to values other than the ones in the global `.gitconfig` file. To do that, edit the `.git/config` file inside each repository where you want custom values to add these lines:
```
[user]
    name = alex-ortan
    email = aortan@umn.edu
```

### Ssh

To make your github development life easier, you'll want to [set up and use a pair of ssh keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/about-ssh). This way you won't have to type your password every time.

1. Check for existing ssh keys. Run `ls -al ~/.ssh` and check for `id_rsa.pub`.
2. If do not already have them, generate ssh keys:
   ```
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
3. Once you have ssh keys, add the private key to the ssh agent:
   ```
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_rsa
   ```
4. Then, add the public key to github: copy the contents of the `id_rsa.pub` file, then in github go to `Settings` > `SSH and GPG keys` > `New SSH key` and paste in the key.


## Vim

Install vim plugins with minpac by opening a vim editor and execute these commands to add the plugins and then check they're correctly installed. These commands are defined in the `vimrc` file.
```
:PackUpdate
:PackStatus
```

