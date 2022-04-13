# dotfiles

## Install dotfiles from this repo

Clone this repo with all of its submodules, and update the submodules to their latest version:
```
git clone --recurse-submodules --remote-submodules --jobs 8 https://github.com/alex-ortan/dotfiles ~/dotfiles

git submodule sync
git submodule update --init --recursive --remote --merge --jobs 8
git pull --recurse-submodules
```

Create a `.secrets` file where you define all the variables needed to fill in the `.template` files. Here's an example, but modify the values as needed:
```
GITHUB_NAME="alex-ortan"
GITHUB_EMAIL="aortan@umn.edu"
GITHUB_OLD_URL="https://github.com"
GITHUB_NEW_URL='"https://github.com"'
GITHUB_PROXY=""
etc
```

Install dotfiles with bashdot.
```
env env $(cat .secrets | xargs)  bashdot/bashdot install default
```

This command is idempotent - meaning in particular that you can rerun it without side effects.


## Github

To make your github development life easier, you'll want to create a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for every device you clone repos on, if you din't already. This token will allow you to access github without typing credentials everytime.

To use this token, either use secure single sign-on (SAML SSO) if your github instance supports it. Otherwise, you can add it manually to each repository's remote URL like so:

```
git remote rm origin
git remote add origin https://alex-ortan:<YOURTOKEN>@github.com/alex-ortan/dotfiles.git
git push --set-upstream origin main
```

In some cases, say if you commit to both a work and personal github account, you'll want to change the name/email you use for a specific repository to values other than the ones in the globel `.gitcinfig` file. To do that, edit the `.git/config` file inside each repository where you want custom values to add these lines:
```
[user]
    name = alex-ortan
    email = aortan@umn.edu
```
