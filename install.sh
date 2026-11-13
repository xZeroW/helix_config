#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}/helix
mkdir -p "$config_dir"

backup_dir=
for file in config.toml languages.toml; do
    target=$config_dir/$file
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ ! -L "$target" ] && cmp -s "$repo_dir/$file" "$target"; then
            echo "Already up to date: $target"
            continue
        fi
        if [ -z "$backup_dir" ]; then
            backup_dir=$(mktemp -d "$config_dir/backup.XXXXXXXX")
        fi
        cp -P "$target" "$backup_dir/$file"
        echo "Backed up $target to $backup_dir/$file"
    fi
    # Remove a symlink rather than overwriting its target.
    if [ -L "$target" ]; then
        rm "$target"
    fi
    cp "$repo_dir/$file" "$target"
    echo "Installed $target"
done
