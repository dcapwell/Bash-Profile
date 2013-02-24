#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin">/dev/null; pwd`

function check-exist-then-create {
  if [ -e "$1" ]; then
    echo "delete $1 and link? [y|n]"
    read del
    if [ "y" == "$del" ]; then
        rm -rf $1
        ln -s $bin/$1
      else
        echo "Skipping $1"
    fi
  fi
}

for n in .vim .vimrc .screen .screenrc
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
      echo "Unable to find profile to write to..."
      exit 1
    fi
  fi

  cat >> $DEST <<EOF

## Bash Extensions
. ~/$bin/.bash_addons
. ~/$bin/.aws
EOF

fi
