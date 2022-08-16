# ruby-install

**WARNING: Your results may vary; user beware!**

## Introduction

This is a simple script to install a local ruby environment for your linux environment. The set up leverages `rbenv` and automates some of the environment configurations.

## Installation

Installation is straight forward. A few things to be aware of.

* `.bashrc` will be updated.
* `.bashrc` will automatically update `rbenv` and associated `ruby-build` plugin.
* `.bashrc` will notify users at login if there is a new version of `ruby` available to install.
* A new `.gemrc` file will be created in the user home director.
* The only gem installed in addition is `bundler`

Below is an example of executing the script.

```shell
> mkdir sandbox
> cd sandbox
> git clone https://github.com/wsgavin/ruby-install
Cloning into 'ruby-install'...
remote: Enumerating objects: 8, done.
remote: Counting objects: 100% (8/8), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 8 (delta 1), reused 8 (delta 1), pack-reused 0
Unpacking objects: 100% (8/8), 2.19 KiB | 1.09 MiB/s, done.

> cd ruby-install
> ./ruby.sh --install

```

Below is an example of the update to the user's `.bashrc` file.

```shell
#### ruby ####

# Automatically update rbenv and builds
git -C ~/.rbenv/ pull 2>/dev/null 1>/dev/null
git -C ~/.rbenv/plugins/ruby-build/ pull 2>/dev/null 1>/dev/null

# Set/update environment variables
export RBENV_VER_INSTALLED="v1.1.2"
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"

# Initialize rbenv
eval "$(rbenv init -)"

# Pull latest version
export RUBY_VER_INSTALLED="2.7.1"
export RUBY_VER_LATEST="$(rbenv install --list 2>/dev/null | sed -n '/^[[:space:]]*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}[[:space:]]*$/ h;${g;p;}' | tr -d '[:space:]')"

# If new version exists, present message at login
if [ "$RUBY_VER_INSTALLED" != "$RUBY_VER_LATEST" ]; then
    echo -e "\x1b[0;32m\xE2\x9E\x9C\x1b[0m New version of ruby is available: $RUBY_VER_INSTALLED -> \x1b[0;32m$RUBY_VER_LATEST\x1b[0m"
fi

#### ruby ####
```
