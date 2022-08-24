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
  grep --exclude-dir={.git,.venv,.ipynb_checkpoints,.docs} -rn . -e $argv
end
