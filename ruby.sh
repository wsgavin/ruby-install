#!/bin/bash

# Setting some color constants
COLOR_GREEN="\x1b[0;32m"
COLOR_RED="\x1b[0;31m"
COLOR_RESET="\x1b[0m"

# Setting some escaped characters
CHAR_ARROW="\xE2\x9E\x9C"
CHAR_XMARK="\xE2\x9C\x97"

RBENV_VERSION=""


function args() {

  if ! options=$(getopt -o '' --long install --long remove -- "$@")
  then
    usage
    exit 1
  fi

  eval set -- "$options"

  while true; do
    case "$1" in
      --install )
        install_ruby;
        break
        ;;
      --remove )
        remove_ruby;
        break
        ;;
      -- ) usage
        break
        ;;
      * ) usage
        ;;
    esac
    shift
  done
}

# TODO think about how the notification works about new versions and how this script would work.
function usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo " --install        Install ruby environment"
  echo " --remove         Remove ruby (and rbenv) installation"

	exit

}


function remove_ruby() {

  # Prompt user for full names used for Git

  yn=""

  while [ -z "$yn" ]
  do

    echo "Removing ruby-install deletes the following files and directories:"
    echo "  - ~/.rbenv"
    echo "  - ~/.gemrc"
    echo "  - ~/.gem"
    echo "  - ~/.bundler"
    echo ""

    # shellcheck disable=SC2039 disable=SC2162
    read -p "Confirm ruby-install removal [Y/n]: " yn

    case "$yn" in
      ""|[Yy])

          yn="y"
          rm -rf ~/.rbenv ~/.gemrc ~/.gem ~/.bundler
          sed -i '/[[:space:]]*#### ruby/, /#### ruby ####\n[[:space:]]*/d' ~/.bashrc

          echo "Removal of ruby-install complete."
      
        ;;
      [Nn])

          echo "Removal of ruby-install was canceled."

        ;;
      *)
        yn=""
        ;;
    esac

    if [ -z "$yn" ]; then
      echo "Something is wrong, let's try again."
    fi

  done

  

  exit

}

function check() {

command -v git >/dev/null 2>&1 ||
  {
    echo -e >&2 "${COLOR_RED}${CHAR_XMARK}${COLOR_RESET} git not installed or in path."
    exit 1
  }

RBENV_VERSION="$(git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort='version:refname' --tags https://github.com/rbenv/rbenv.git '*.*.*' | tail --lines=1 | cut --delimiter='/' --fields=3)" ||
  {
    echo -e >&2 "${COLOR_RED}${CHAR_XMARK}${COLOR_RESET} cannot reach GitHub for rbenv."
    exit 1
  }

! command -v rbenv >/dev/null 2>&1 ||
  {
    echo -e >&2 "${COLOR_RED}${CHAR_XMARK}${COLOR_RESET} rbenv is already installed."
    exit 1
  }

}

function install_ruby() {

  check

  echo
  echo Installing and configuring ruby...
  echo
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  echo
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

  # TODO: check if file exists maybe
  echo
  echo Initialize .gemrc
  echo "gem: --no-document" > ~/.gemrc
  echo

  export PATH="$HOME/.rbenv/bin:$PATH"
  
  eval "$(rbenv init -)"

  # Grabbing the latest version release of ruby.
  # shellcheck disable=SC2016
  RUBY_VER="$(rbenv install --list 2>/dev/null | sed -n '/^[[:space:]]*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}[[:space:]]*$/ h;${g;p;}' | tr -d '[:space:]')"

  cat << EOT >> "${HOME}"/.bashrc

#### ruby ####

# Automatically update rbenv and builds
git -C ~/.rbenv/ pull 2>/dev/null 1>/dev/null
git -C ~/.rbenv/plugins/ruby-build/ pull 2>/dev/null 1>/dev/null

# Set/update environment variables
export RBENV_VER_INSTALLED="${RBENV_VERSION}"
export RBENV_ROOT="\$HOME/.rbenv"
export PATH="\$RBENV_ROOT/bin:\$PATH"

# Initialize rbenv
eval "\$(rbenv init -)"

# Pull latest version
export RUBY_VER_INSTALLED="${RUBY_VER}"
export RUBY_VER_LATEST="\$(rbenv install --list 2>/dev/null | sed -n '/^[[:space:]]*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}[[:space:]]*\$/ h;\${g;p;}' | tr -d '[:space:]')"

# If new version exists, present message at login
if [ "\$RUBY_VER_INSTALLED" != "\$RUBY_VER_LATEST" ]; then
    echo -e "${COLOR_GREEN}${CHAR_ARROW}${COLOR_RESET} New version of ruby is available: \$RUBY_VER_INSTALLED -> ${COLOR_GREEN}\$RUBY_VER_LATEST${COLOR_RESET}"
fi

#### ruby ####

EOT

  rbenv install "$RUBY_VER"
  rbenv global "$RUBY_VER"

  gem update
  gem cleanup

  gem install bundler

  rbenv rehash

}

args "$@"
