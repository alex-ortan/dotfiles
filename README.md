# dotfiles


## Install dotfiles from this repo

Clone this repo with all of its submodules:
```
git clone --recurse-submodules --remote-submodules --jobs 8 git@github.com:alex-ortan/dotfiles.git
cd dotfiles
```

Update the submodules to their latest version:
```
git submodule sync
git submodule update --init --recursive --remote --merge --jobs 8
git pull --recurse-submodules
```

Create a `.secrets` file where you define all the variables needed to fill in the `.template` files. Here's an example, but modify the values as needed:
```
DWD="/home/alex/MyFavoriteDirectory"
HTTP_PROXY=""
NO_PROXY=""
GITHUB_NAME="alex-ortan"
GITHUB_EMAIL="aortan@umn.edu"
GITHUB_SHORT_URL="https://github.com"
GITHUB_URL='"https://github.com"'
GITHUB_PROXY=""
ROOT_CA=""
etc
```

Install dotfiles with bashdot.
```
env $(cat .secrets | xargs)  bashdot/bashdot install default
```

This command is idempotent - meaning in particular that you can rerun it without side effects.


### Adding a submodule

```
git submodule add https://github.com/tarjoilija/zgen default/zgen 

env $(cat .secrets | xargs)  bashdot/bashdot install default
```


## GitHub

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


### HTTPS

If you cannot use ssh for some reason, you'll have to use the https protocol. If you use https, you can authenticate via a personal access token (PAT). [Create a PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for every device you clone repos on.

To avoid typing the username and PAT every time you need to authenticate, use git's [credential store helper](https://git-scm.com/docs/git-credential-store). The first time you access a non-public repository, or try to perform an operation which requires authentication, Git will prompt you to provide credentials. You will provide your Personal Access Token (not your password) as the username, and no password, and this will be stored by the 'store' credential helper. You will see this stored in ~/.git-credentials, so you must ensure that this file is kept confidential.

*Note:* You may be tempted to use the more secure GitHub CLI instead of the credentials store helper to store your credentials locally. But you can't use it behind a proxy.


## AWS access

To make access to AWS or other S3 cloud storage easier, store your access keys for different profiles in `~/.aws/credentials`:
```
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY

[dev]
aws_access_key_id = $AWS_ACCESS_KEY_ID_DEV
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_DEV

etc
```


## Vim

Install vim pull --recurse-submodule plugins with minpac by opening a vim editor and execute these commands to add the plugins and then check they're correctly installed. These commands are defined in the `vimrc` file.
```
:PackUpdate
:PackStatus
```


## WSL

For everything to work nicely in WSL, you need to install and use the Windows Terminal.

For everything to look pretty, install the [Dracula theme for Windows Terminal](https://draculatheme.com/windows-terminal).

Enable permissions to be set from Linux.
```
sudo cp $PWD/wsl.conf /etc/
```


## ZSH

You might need to set stricter permissions for zsh to work properly:
```
compaudit | xargs chmod go-w 
```

(deprecated?) Manually add dracula theme from dracula-zsh submodule to zsh:
```
cp dracula-zsh/dracula.zsh-theme default/zgen/robbyrussell/oh-my-zsh-master/themes
cp -r dracula-zsh/lib default/zgen/robbyrussell/oh-my-zsh-master/themes
```

Zsh might require additional fonts to work in WSL:
```
sudo apt-get install fonts-powerline
sudo apt-get install powerline
```

### zgen

Run this every time you add or remove zgen plugins:
```
zgen reset
```

### slimzsh

The slimzsh submodule is relying on a deprecated branch (master) of the pure repo, so that needs to be switched to an existing branch (main):c
```
cd default/slimzsh
git submodule set-branch --branch main pure
```


