#!/bin/zsh
# Define a function which rename a `target` file to `target.backup` if the file
# exists and if it's a 'real' file, ie not a symlink
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.bak"
      echo "::: $target backed up to $target.bak"
    fi
  fi
}

symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    echo "::: Symlinking your new $link"
    ln -nsf $file $link
  fi
}

zparseopts -D -F -K   \
  {a,-all}=opts_all   \
  {f,-file}=opts_file \
  {d,-dir}=opts_dir   \
  {z,-zsh}=opts_zsh 


# For all files `$name` in the present folder except `*.sh`, `README.md`, `settings.json`,
# and `config`, backup the target file located at `~/.$name` and symlink `$name` to `~/.$name`
if [[ $#opts_all || $#opts_file ]]; then
  for fp in `find ./configs -mindepth 1 -maxdepth 1`; do
    name=${fp##*/}
    if [ ! -d "$name" ]; then
      target="$HOME/$name"
      backup $target
      symlink "$PWD/$fp" $target
    fi
  done
fi

if [[ $#opts_all || $#opts_dir ]]; then
  for fp in `find ./configs -mindepth 1 -maxdepth 1`; do
    name=${fp##*/}
    if [ -d "$name" ]; then
      target="$HOME/$name"
      backup $target
      symlink "$PWD/$fp" $target
    fi
  done
fi


if [[ $#opts_all || $#opts_zsh ]]; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi

  if [ ! -d "$HOME/.zsh/typewritten" ]; then
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/reobin/typewritten.git "$HOME/.zsh/typewritten"
  fi
fi

# Install zsh-syntax-highlighting plugin
if [[ $#opts_all || $#opts_zsh ]]; then
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

# Refresh the current terminal with the newly installed configuration
exec zsh

