# Source local virtual environment
function s
    source .venv/bin/activate.fish
end

# Start jupyter notebook
function jn
    jupyter notebook
end

# Shortcut for finding files
function f
  find . -type f | grep -v .svn | grep -v .git | grep -i $argv
end

# Shortcut for finding text in files
function g
  set -l exclude **.pyc
  grep --exclude-dir={.git,.venv,.ipynb_checkpoints,.docs} --exclude=$exclude -rn . -e $argv
end
