#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases

# variables
repo_dir="$HOME/.src/scripts"
if [[ ! -d "$repo_dir" ]]; then
    die "Repository directory $repo_dir does not exist."
fi
stow_dir="$repo_dir/stow"
if [[ ! -d "$stow_dir" ]]; then
    die "Stow directory $stow_dir does not exist."
fi
source "$stow_dir/common/functions.sh" || die "Could not source functions.sh."
backup_dir="$HOME/tmp/dotfile_backup"
if [[ ! -d "$backup_dir" ]]; then
    mkdir -p "$backup_dir" || die "Could not create backup directory $backup_dir."
fi

# Backup files on new installs
backup() {
    local pkg;
    local src_dir;
    src_dir="$stow_dir/$1"
    if [[ ! -d "$src_dir" ]]; then
        die "Source directory $src_dir does not exist."
    fi
    find "$src_dir" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' d; do
        pkg=$(basename "$d")
        mkdir -p "$backup_dir/$pkg" || die "Could not create backup directory $backup_dir/$pkg."
        find "$d" -maxdepth 1 \(-type f -o -type d\) -exec mv {} "$backup_dir/$pkg/" \;
    done
}

update () {
    local src_dir;
    src_dir="$stow_dir/$2"
    if [[ ! -d "$src_dir" ]]; then
        die "Source directory $src_dir does not exist."
    fi
    find "$src_dir" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' f; do
        pkg="$(basename "$f")"
        if [[ $1 = "true" ]]; then
            stow -v -d "$src_dir" -t "$HOME" "$pkg"
        elif [[ $1 = "false" ]]; then
            stow -v -R -d "$src_dir" -t "$HOME" "$pkg"
        fi
    done
}

main () {
    require_cmd git
    require_cmd stow

    # By default we are in update mode
    INSTALL_MODE=false
    if [[ $(uname) = "Linux" ]]; then
        my_os="linux"
    elif [[ $(uname) = "Darwin" ]]; then
        my_os="macos"
    else
        die "$(uname) is not supported"
    fi
    
    # Loop through arguments
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --install) INSTALL_MODE=true; shift ;;
        *) die "Unsupported option $1" ;;
      esac
    done

    if [[ "$INSTALL_MODE" = "true" ]]; then
        mkdir -p "$backup_dir"
        backup "common"
        backup "$my_os"
        update true "common"
        update true "$my_os"
    else
        git -C $repo_dir pull
        update false "common"
        update false "$my_os"
    fi
}

main "$@"