# dotfiles

## Install dotfiles from this repo

Clone this repo with all of its submodules, and update the submodules to their latest version:
```
git clone --recurse-submodules --remote-submodules --jobs 8 https://github.com/alex-ortan/dotfiles ~/dotfiles

git submodule sync
git submodule update --init --recursive --remote --merge --jobs 8
git pull --recurse-submodules
```

Create a `.secrets` file where you define all the variables needed to fill in the `.template` files.
```
GITHUB_NAME="the username you use for the github account you want to connect to by default"
GITHUB_EMAIL="the corresponding email"
etc
```

Install dotfiles with bashdot.
```
env env $(cat .secrets | xargs)  bashdot/bashdot install default
```

## Accessing github without typing credentials everytime

Create a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for the device you just cloned this repo to, if you don't already have one. Add your token to the remote URL:
```
git remote rm origin
git remote add origin https://alex-ortan:<YOURTOKEN>@github.com/alex-ortan/dotfiles.git
git push --set-upstream origin main
```
