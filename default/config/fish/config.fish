source ~/.config/fish/functions/aliases.fish

fish_add_path -m ~/.local/bin

if status is-interactive
and not set -q TMUX
    exec tmux
end
