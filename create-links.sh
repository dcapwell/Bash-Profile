#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin">/dev/null; pwd`

function check-exist-then-create {
  if [ -e "$1" ]; then
    name=`basename $1`
    echo "delete $name and link? [y|n]"
    read del
    if [ "y" == "$del" ]; then
        rm -rf $HOME/$name
        ln -s $1 $HOME/$name
      else
        echo "Skipping $1"
    fi
  fi
}

for n in $bin/.vim $bin/.vimrc $bin/.screen $bin/.screenrc $bin/.gitconfig $bin/.gitignore
do
  check-exist-then-create $n
done

echo "Append add-ons to bash? [y|n]"
read addons
if [ "y" == "$addons" ]; then
  if [ -e ~/.bashrc ]; then
    DEST=~/.bashrc
  else
    if [ -e ~/.bash_profile ]; then
      DEST=~/.bash_profile
    else
      ## Assuming mac since thats the computer I use the most
      DEST=~/.bash_profile
      touch $DEST
    fi
  fi

  cat >> $DEST <<EOF

## Bash Extensions
. $bin/bash_addons
. $bin/aws
EOF

fi

SSH_DIR=~/.ssh
if [ ! -d "$SSH_DIR" ]; then
  echo "No ssh directory found, should I create one and a key as well? [y|n]"
  read ssh_dir
  if [ "y" == "$ssh_dir" ]; then
    mkdir $SSH_DIR
    chmod 700 $SSH_DIR
    ( cd $SSH_DIR ; ssh-keygen -t dsa )
  fi
fi
