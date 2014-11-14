#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin">/dev/null; pwd`

function check-exist-then-create {
  if [ -e "$1" ]; then
    path=$1
    #name=`basename $path`
    name=`sed "s;$bin/;;" <<< $path`
    echo "delete $name and link $path? [y|n]"
    read del
    if [ "y" == "$del" ]; then
        rm -rf $HOME/$name
        ln -s $path $HOME/$name
      else
        echo "Skipping $1"
    fi
  fi
}

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

for n in $bin/.vim $bin/.vimrc $bin/.screen $bin/.screenrc $bin/.gitconfig $bin/.gitignore $bin/.ssh/config $bin/.bash_color $bin/.tmux.conf $bin/.scala-repl-addons
do
  check-exist-then-create $n
done

if [ ! -d "$HOME/bin" ]; then
  mkdir -p "$HOME/bin"
  cat >> $DEST <<EOF
export PATH="\$PATH:\$HOME/bin"
EOF
fi

for b in `ls bin`
do
  echo "Adding $b to $HOME/bin/$b"
  ln -s $PWD/bin/$b $HOME/bin/$b
done

which brew 2> /dev/null
if [ $? -ne 0 ]; then
  ## install brew if missing
  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
fi

echo 'Setup brew? [y|n]'
read brew_setup
if [ "y" == "$brew_setup" ]; then
  /usr/local/bin/brew install wget tmux tree curl reattach-to-user-namespace boot2docker docker
fi

echo "Append add-ons to bash? [y|n]"
read addons
if [ "y" == "$addons" ]; then
  cat >> $DEST <<EOF

## Bash Extensions
. $bin/.bash_color
. $bin/bash_addons
. $bin/docker_addons
. $bin/aws

## Scala Addons
alias scala="scala -i ~/.scala-repl-addons"
EOF

  ## See you space cowboy
  pushd ~/
  wget 'https://gist.githubusercontent.com/danielrehn/d2e6f2129e5f853c3166/raw/9dff7165ed7d47a3f52b411653707cb2f38ce3af/seeyouspacecowboy.sh'
  popd
  cat >> ~/.bash_logout <<EOF
if [ "\$TERM" != "screen" ]; then
  sh ~/seeyouspacecowboy.sh; sleep 2
fi
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

echo 'Add git completion? [y|n]'
read gitcomplete
if [ "y" == "$gitcomplete" ]; then
  wget "https://raw.github.com/git/git/v`git --version | awk '{print $3}'`/contrib/completion/git-completion.bash"
  wget "https://raw.github.com/git/git/v`git --version | awk '{print $3}'`/contrib/completion/git-prompt.sh"
  mv git-completion.bash ~/.git-completion.bash
  ## bash-addon will source this since screen doesn't seem to pick it up
  mv git-prompt.sh ~/.git-prompt.sh
  cat >> $DEST <<EOF

## Git-Bash integration
source ~/.git-completion.bash
EOF
fi

