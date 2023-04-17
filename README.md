Contents
========

- [Install dotfiles from this repo](#Install dotfiles from this repo)
    - [Adding a submodule](#Install dotfiles from this repo#Adding a submodule)
- [GitHub](#GitHub)
    - [Ssh](#GitHub#Ssh)
    - [HTTPS](#GitHub#HTTPS)
- [AWS access](#AWS access)
- [WSL](#WSL)
- [Fish](#Fish)
    - [Troubleshooting](#Fish#Troubleshooting)
- [ZSH](#ZSH)
    - [zgen](#ZSH#zgen)
    - [slimzsh](#ZSH#slimzsh)
- [Vim](#Vim)


Install dotfiles from this repo
===============================


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

Install dotfiles with bashdot. If using bash, run:
```bash
env $(cat .secrets | xargs) bashdot/bashdot install default
```
If using fish, run:
```fish
eval (cat .secrets) bashdot/bashdot install default
```
This command is idempotent - meaning in particular that you can rerun it without side effects.


## Adding a submodule

To add a new submodule:
```
git submodule add https://github.com/jorgebucaran/fisher fisher
```

If you add a submodule inside one of the profiles (e.g. default) and want that to show up as a dotfile, don't forget to rerun the `bashdot install` command above. 

By default, submodules will pull from the master branch of a repository. If you want to change that, you can do:
```
git submodule set-branch main fisher
```
or manually edit the `.gitmodules` file to add the branch line:
```
[submodule "fisher"]
    path = fisher
    url = https://github.com/jorgebucaran/fisher
    branch = main
```



GitHub
======

In some cases, say if you commit to both a work and personal github account, you'll want to change the name/email you use for a specific repository to values other than the ones in the global `.gitconfig` file. To do that, edit the `.git/config` file inside each repository where you want custom values to add these lines:
```
[user]
    name = alex-ortan
    email = aortan@umn.edu
```


## Ssh

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


## HTTPS

If you cannot use ssh for some reason, you'll have to use the https protocol. If you use https, you can authenticate via a personal access token (PAT). [Create a PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for every device you clone repos on.

To avoid typing the username and PAT every time you need to authenticate, use git's [credential store helper](https://git-scm.com/docs/git-credential-store). The first time you access a non-public repository, or try to perform an operation which requires authentication, Git will prompt you to provide credentials. You will provide your Personal Access Token (not your password) as the username, and no password, and this will be stored by the 'store' credential helper. You will see this stored in ~/.git-credentials, so you must ensure that this file is kept confidential.

*Note:* You may be tempted to use the more secure GitHub CLI instead of the credentials store helper to store your credentials locally. But you can't use it behind a proxy.



AWS access
==========

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



WSL
===

For everything to work nicely in WSL, you need to install and use the Windows Terminal.

For everything to look pretty, install the [Dracula theme for Windows Terminal](https://draculatheme.com/windows-terminal).

[Optional] Reuse existing WSL settings:
```
cp default/windows_terminal_settings.json /mnt/c/Users/$USERNAME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
```

Enable permissions to be set from Linux.
```
sudo cp default/wsl.conf /etc/
```



Fish
====


Install the latest version of fish by first adding the fish-shell ppa:
```
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install fish
```

Configure fish by running the `fish_config` and following the instructions:
```
fish_config prompt choose
```

Install plugins using the fisher plugin manager, included in this repo as a submodule:
```
source fisher/functions/fisher.fish
fisher install fisher/
fisher install acomagu/fish-async-prompt
```


## Troubleshooting

1. The `apt-add-repository` command fails with the error `ImportError: cannot import name '_gi' from partially initialized module 'gi'`.
    This is happens because Ubuntu doesn't like your default `python3`. Likely you changed the default `python3` after installing Ubuntu, and now there are conflicts between the old and the new `python3` defaults. Try running the `apt-add-repository` explicitly using a different `python3` version:
    ```
    sudo python3.8 /usr/bin/apt-add-repository ppa:fish-shell/release-3
    ```
2. The `apt-add-repository` command times out because of a connection issue. 
   This happens when you're behind a proxy. To make sure `apt-add-repository` uses your proxy, you have to set the `HTTP_PROXY` environment variable appropriately, and make sure tell `sudo` to preserve the environment with the -E option:
   ```
   epxort HTTPS_PROXY=YOUR_OWN_PROXY
   sudo -E python3.8 /usr/bin/apt-add-repositoryppa:fish-shell/release-3
   ```
3. The `fish_config` command fails. If you're on WSL, might need to set this somewhere:
   ```
   file://wsl%24/Ubuntu-20.04
   ```



ZSH
===

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


## zgen

Run this every time you add or remove zgen plugins:
```
zgen reset
```


## slimzsh

The slimzsh submodule is relying on a deprecated branch (master) of the pure repo, so that needs to be switched to an existing branch (main):c
```
cd default/slimzsh
git submodule set-branch --branch main pure
```



Vim
===

Install vim plugins with minpac by opening a vim editor and execute these commands to add the plugins and then check they're correctly installed. These commands are defined in the `vimrc` file.
```
:PackUpdate
:PackStatus
```

Neovim
======

Install the latest stable release by downloading [`nvim.appimage`](https://github.com/neovim/neovim/releases/latest/download/nvim.appimage), making sure it is executable, and placing it in your working directory `$DWD`.

Install plugins with minpac by opening a neovim editor and execute these commands to add the plugins and then check they're correctly installed. These commands are defined in the `config/nvim/init.vim` file.
```
:PackUpdate
:PackStatus
```

Python
======

If you use python, this is what you need to do to install the [pylsp](https://github.com/python-lsp/python-lsp-server) Language Server for it. This assumes you already 
have python 3.7+ installed on your system.

```bash
pip install "python-lsp-server[all]"
pip install python-lsp-ruff
```
