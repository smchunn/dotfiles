#!/bin/zsh
# Define a function which rename a `target` file to `target.backup` if the file
# exists and if it's a 'real' file, ie not a symlink
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.bak"
      echo "> $target backed up to $target.bak"
    fi
  fi
}

symlink() {
  file=$1
  link=$2
  echo "> Symlinking $link to $file"
  ln -nsf $file $link
}

zparseopts -D -F -K   \
  {a,-all}=opts_all   \
  {f,-file}=opts_file \
  {d,-dir}=opts_dir   \
  {z,-zsh}=opts_zsh   \
  {t,-tpm}=opts_tpm


# For all files `$name` in the present folder except `*.sh`, `README.md`, `settings.json`,
# and `config`, backup the target file located at `~/.$name` and symlink `$name` to `~/.$name`
if (($#opts_all + $#opts_file > 0)); then
  echo "Linking Files..."
  for fp in `find ~+/configs -not -name ".DS_Store" -mindepth 1 -maxdepth 1`; do
    name=${fp##*/}
    if [ ! -d "$name" ]; then
      target="$HOME/$name"
      backup $target
      symlink "$fp" $target
    fi
  done
fi

if (($#opts_all + $#opts_dir > 0)); then
  echo "Linking Dirs..."
  for fp in `find ~+/configs -mindepth 1 -maxdepth 1`; do
    name=${fp##*/}
    if [ -d "$name" ]; then
      target="$HOME/$name"
      backup $target
      symlink "$fp" $target
    fi
  done
fi


if (($#opts_all + $#opts_zsh > 0)); then
  echo "Installing OMZ..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi
  ZSH_THEMES_DIR="$HOME/.oh-my-zsh/custom/themes"
  if [ ! -d "$ZSH_THEMES_DIR/typewritten" ]; then
    git clone https://github.com/reobin/typewritten.git $ZSH_THEMES_DIR/typewritten
  fi
  ln -nsf "$ZSH_THEMES_DIR/typewritten/typewritten.zsh-theme" "$ZSH_THEMES_DIR/typewritten.zsh-theme"
  ln -nsf "$ZSH_THEMES_DIR/typewritten/async.zsh" "/$ZSH_THEMES_DIR/async"
fi

# Install zsh-syntax-highlighting plugin
if (($#opts_all + $#opts_zsh > 0)); then
  CURRENT_DIR=`pwd`
  ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
  mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"
  if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    echo "::: Installing zsh plugin 'zsh-syntax-highlighting'..."
    git clone https://github.com/zsh-users/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting
  fi

  cd "$CURRENT_DIR"
fi


# Install tpm
if (($#opts_all + $#opts_tpm > 0)); then
  echo "Installing TPM..."
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "::: Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
fi


