#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}/helix
bin_dir=${HOME}/.local/bin

install_packages() {
    if command -v brew >/dev/null 2>&1 && [ "$(uname -s)" = Darwin ]; then
        brew install "$@"
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed -- "$@"
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y "$@"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$@"
    elif command -v brew >/dev/null 2>&1; then
        brew install "$@"
    else
        echo 'Unsupported package manager. Install dependencies listed in README.md manually.' >&2
        exit 1
    fi
}

packages=
for pair in 'git:git' 'curl:curl' 'lazygit:lazygit' 'ruff:ruff'; do
    cmd=${pair%%:*}
    package=${pair#*:}
    if ! command -v "$cmd" >/dev/null 2>&1; then packages="$packages $package"; fi
done
if ! command -v helix >/dev/null 2>&1 && ! command -v hx >/dev/null 2>&1; then
    packages="$packages helix"
fi
if ! command -v npm >/dev/null 2>&1; then
    if command -v pacman >/dev/null 2>&1; then packages="$packages npm"
    elif command -v apt-get >/dev/null 2>&1; then packages="$packages npm"
    elif command -v dnf >/dev/null 2>&1; then packages="$packages npm"
    else packages="$packages node"; fi
fi
if [ -n "$packages" ]; then
    # Package names above are fixed literals, intentionally split into arguments.
    # shellcheck disable=SC2086
    install_packages $packages
fi

if ! command -v rustup >/dev/null 2>&1; then
    echo 'Installing Rust via rustup (https://rustup.rs).'
    rustup_installer=$(mktemp)
    trap 'rm -f "$rustup_installer"' EXIT HUP INT TERM
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$rustup_installer"
    sh "$rustup_installer" -y --no-modify-path
    rm -f "$rustup_installer"
    trap - EXIT HUP INT TERM
fi
PATH="$HOME/.cargo/bin:$bin_dir:$PATH"
export PATH
rustup component add rust-analyzer clippy
for tool in bacon zellij; do
    if ! command -v "$tool" >/dev/null 2>&1; then cargo install --locked "$tool"; fi
done
node_packages=
if ! command -v pyright-langserver >/dev/null 2>&1; then node_packages="$node_packages pyright"; fi
if ! command -v prettier >/dev/null 2>&1; then node_packages="$node_packages prettier"; fi
if [ -n "$node_packages" ]; then
    # shellcheck disable=SC2086
    npm install -g --prefix "$HOME/.local" $node_packages
fi

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

mkdir -p "$bin_dir"
for file in hx-lazygit hx-bacon; do
    target=$bin_dir/$file
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ ! -L "$target" ] && cmp -s "$repo_dir/helpers/$file" "$target"; then continue; fi
        if [ -z "$backup_dir" ]; then backup_dir=$(mktemp -d "$config_dir/backup.XXXXXXXX"); fi
        cp -P "$target" "$backup_dir/$file"
        echo "Backed up $target to $backup_dir/$file"
        if [ -L "$target" ]; then rm "$target"; fi
    fi
    cp "$repo_dir/helpers/$file" "$target"
    chmod +x "$target"
    echo "Installed $target"
done

case ${SHELL:-} in
    */fish)
        fish_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}/fish/functions
        mkdir -p "$fish_dir"
        target=$fish_dir/hx.fish
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ ! -L "$target" ] && cmp -s "$repo_dir/shell/hx.fish" "$target"; then
                echo "Already up to date: $target"
                echo "Ensure $bin_dir and $HOME/.cargo/bin are on your PATH."
                exit 0
            fi
            if [ -z "$backup_dir" ]; then backup_dir=$(mktemp -d "$config_dir/backup.XXXXXXXX"); fi
            cp -P "$target" "$backup_dir/hx.fish"
            echo "Backed up $target to $backup_dir/hx.fish"
            if [ -L "$target" ]; then rm "$target"; fi
        fi
        cp "$repo_dir/shell/hx.fish" "$target"
        echo "Installed $target"
        ;;
    *)
        target=$config_dir/hx.sh
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ -L "$target" ] || ! cmp -s "$repo_dir/shell/hx.sh" "$target"; then
                if [ -z "$backup_dir" ]; then backup_dir=$(mktemp -d "$config_dir/backup.XXXXXXXX"); fi
                cp -P "$target" "$backup_dir/hx.sh"
                echo "Backed up $target to $backup_dir/hx.sh"
                if [ -L "$target" ]; then rm "$target"; fi
            fi
        fi
        cp "$repo_dir/shell/hx.sh" "$target"
        echo "Installed $target; source it in your shell configuration to enable the hx wrapper."
        ;;
esac
echo "Ensure $bin_dir and $HOME/.cargo/bin are on your PATH."
