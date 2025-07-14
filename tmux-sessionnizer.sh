#!/usr/bin/env bash

# Script created by ThePrimegean: https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

base_path="$HOME/Programming/"

# append the arg passed in to the base_path
if [[ $# -eq 1 ]]; then
    selected="${base_path}${1}"
else
    selected=$(find $base_path -mindepth 1 -maxdepth 1 -type d | fzf)
fi

# silent exit if script is forcefully quit
if [[ -z $selected ]]; then
    exit 0
fi

# check if the chosen directory from the arg exists
if [[ ! -d $selected ]]; then
    echo "Directory does not exist: $selected"
    exit 1
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# if you are not in a tmux client and a tmux server is not running then create a new 
# session
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

# if there is a tmux server that is running aleady than just switch to the session
if [[ -n $TMUX ]]; then 
    tmux switch-client -t $selected_name
# if not then create a new session
else
    tmux attach-session -t $selected_name
fi
