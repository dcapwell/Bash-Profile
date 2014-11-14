#!/bin/bash

set -e

if ! type nix-env > /dev/null ; then 
  bash <(curl https://nixos.org/nix/install)
  export PATH="~/.nix-profile/bin/:~/.nix-profile/sbin/:$PATH"
fi

# Ruby and Nix don't go hand in hand ATM
# Don't use nix for Ruby packages
packages=(
  clojure-1.6.0
  scala-2.11.0 
  ghc-7.8.3
  apache-maven-3.1.1
  tree-1.7.0
  curl-7.36.0
  tmux-1.9a
  wget-1.15
  git-2.1.0
)


nix-env -i "${packages[@]}"
