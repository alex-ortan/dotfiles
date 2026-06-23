source ~/.config/fish/functions/aliases.fish

fish_add_path -m ~/.local/bin
fish_add_path -m ~/minio-binaries
fish_add_path -m /home/alex/texlive/2025/bin/x86_64-linux/

if status is-interactive
    and not set -q TMUX
    exec tmux new-session -A -D -s main
end
