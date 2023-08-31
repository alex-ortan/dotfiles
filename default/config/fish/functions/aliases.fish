# Remap vi command to neovim
function vi
    $HOME/nvim.appimage $argv
end

# Source local virtual environment
function s
    source .venv/bin/activate.fish
end

# Start jupyter notebook
function jn
    jupyter notebook
end

# Start jupyter lab
function jj
    jupyter lab
end

# Shortcut for finding files
function f
  find . -type f | grep -v .svn | grep -v .git | grep -i $argv
end

# Shortcut for finding text in files
function g
  set -l exclude **.pyc
  grep --exclude-dir={.git,.venv,.ipynb_checkpoints,.docs,.pyc} --exclude=$exclude -rn . -e $argv
end
