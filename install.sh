#!/bin/bash

# Define a function which renames a `target` file to `target.bak` if the file
# exists and if it's a 'real' file, i.e., not a symlink
backup() {
  target=$1
  date=$(date '+%Y-%m-%d_%H:%M:%S')
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.$date.bak"
      echo "> $target backed up to $target.$date.bak"
    fi
  fi
}

symlink() {
  file=$1
  link=$2
  echo "> Symlinking $link to $file"
  ln -nsf "$file" "$link"
}

# Initialize option variables
opts_update=false
opts_force=false

# Parse options using getopts
while getopts "uf" opt; do
  case $opt in
    u) opts_update=true ;;
    f) opts_force=true ;;
    *) echo "Invalid option"; exit 1 ;;
  esac
done

echo "--- Fish:"
# Detect OS and install/update Fish
if [[ "$(uname)" == "Darwin" ]]; then
  echo "::: Detected macOS. Checking for Homebrew Fish..."
  if ! brew list fish &>/dev/null; then
    echo "::: Zsh not found. Installing Fish via Homebrew..."
    brew install fish
  elif [ "$opts_update" == true ]; then
    echo "::: Updating Fish via Homebrew..."
    brew upgrade fish
  else
    echo "::: Fish is already installed. Skipping installation."
  fi
elif [[ "$(uname -s)" == "Linux" ]]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
      echo "::: Detected Ubuntu. Checking for apt Fish..."
      if ! dpkg -l | grep -q fish; then
        echo "::: Fish not found. Installing Fish via apt..."
        sudo apt update && sudo apt install -y fish
      elif [ "$opts_update" == true ]; then
        echo "::: Updating Fish via apt..."
        sudo apt update && sudo apt upgrade -y fish
      else
        echo "::: Fish is already installed. Skipping installation."
      fi
    fi
  fi
fi

echo "--- Linking Files:"
find "$(pwd)/configs" -mindepth 1 -maxdepth 1 -type f -not -name ".DS_Store" -print0 | while IFS= read -r -d '' fp; do
  name=${fp##*/}
  # Check if fp is not a directory and either opts_force is true or the target is not a symlink
  if [ -f "$fp" ]; then
    if [[ "$opts_force" == true || ! -h "$HOME/$name" ]]; then
      target="$HOME/$name"
      backup "$target"
      symlink "$fp" "$target"
    else
      echo "::: $HOME/$name linked, skipping..."
    fi
  fi
done

echo "--- Linking Dirs:"
find "$(pwd)/configs" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' fp; do
  name=${fp##*/}
  # Check if fp is a directory and either opts_force is true or the target is not a symlink
  if [ -d "$fp" ]; then
    if [[ "$opts_force" == true || ! -h "$HOME/$name" ]]; then
      if [[ "$name" == *.os && -f "${fp}/${name%.*}.$(uname)" ]]; then
        target="$HOME/$name"
        backup "$target"
        symlink "${fp}/${name%.*}.$(uname)" "$target"
      else
        target="$HOME/$name"
        backup "$target"
        symlink "$fp" "$target"
      fi
    else
      echo "::: $HOME/$name linked, skipping..."
    fi
  fi
done


echo "--- TPM:"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "::: Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
elif [ "$opts_update" == true ]; then
  echo "::: Updating tmux plugin manager..."
  (cd "$HOME/.tmux/plugins/tpm" && git pull)
else
  echo "::: 'TPM' directory exists, skipping..."
fi
