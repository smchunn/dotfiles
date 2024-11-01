
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

echo "--- Zsh:"
# Detect OS and install/update Zsh
if [[ "$(uname)" == "Darwin" ]]; then
  echo "::: Detected macOS. Checking for Homebrew Zsh..."
  if ! brew list zsh &>/dev/null; then
    echo "::: Zsh not found. Installing Zsh via Homebrew..."
    brew install zsh
  elif [ "$opts_update" == true ]; then
    echo "::: Updating Zsh via Homebrew..."
    brew upgrade zsh
  else
    echo "::: Zsh is already installed. Skipping installation."
  fi
elif [[ "$(uname -s)" == "Linux" ]]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
      echo "::: Detected Ubuntu. Checking for apt Zsh..."
      if ! dpkg -l | grep -q zsh; then
        echo "::: Zsh not found. Installing Zsh via apt..."
        sudo apt update && sudo apt install -y zsh
      elif [ "$opts_update" == true ]; then
        echo "::: Updating Zsh via apt..."
        sudo apt update && sudo apt upgrade -y zsh
      else
        echo "::: Zsh is already installed. Skipping installation."
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
      target="$HOME/$name"
      backup "$target"
      symlink "$fp" "$target"
    else
      echo "::: $HOME/$name linked, skipping..."
    fi
  fi
done

echo "--- OMZ:"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
elif [ "$opts_update" == true ]; then
  (omz update)
fi

ZSH_THEMES_DIR="$HOME/.oh-my-zsh/custom/themes"

if [[ ! -d "$ZSH_THEMES_DIR/typewritten" ]]; then
  echo "::: Installing zsh theme: 'typewritten'..."
  git clone https://github.com/reobin/typewritten.git "$ZSH_THEMES_DIR/typewritten"
elif [ "$opts_update" == true ]; then
  echo "::: 'typewritten' updating..."
  (cd "$ZSH_THEMES_DIR/typewritten" && git pull)
else
  echo "::: 'typewritten' directory exists, skipping..."
fi

ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
if [ ! -d "$ZSH_PLUGINS_DIR" ]; then
  mkdir -p "$ZSH_PLUGINS_DIR"
fi

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  echo "::: Installing zsh plugin 'zsh-syntax-highlighting'..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
elif [ "$opts_update" == true ]; then
  echo "::: Updating zsh plugin 'zsh-syntax-highlighting'..."
  (cd "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" && git pull)
else
  echo "::: 'zsh-syntax-highlighting' directory exists, skipping..."
fi

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  echo "::: Installing zsh plugin 'zsh-autosuggestions'..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
elif [ "$opts_update" == true ]; then
  echo "::: Updating zsh plugin 'zsh-autosuggestions'..."
  (cd "$ZSH_PLUGINS_DIR/zsh-autosuggestions" && git pull)
else
  echo "::: 'zsh-autosuggestions' directory exists, skipping..."
fi

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
