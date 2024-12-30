source ~/.config/fish/functions/aliases.fish

fish_add_path -m ~/.local/bin
fish_add_path -m ~/minio-binaries

if status is-interactive
    and not set -q TMUX
    exec tmux new-session -A -D -s main
end
