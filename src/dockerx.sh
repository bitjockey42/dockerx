#!/usr/bin/env

install() {
  ## Install homebrew if not already installed
  if ! homebrew_installation="$(type -p "$brew)" || [ -z "$homebrew_installation" ]; then
    echo '[homebrew](http://brew.sh) is not installed. Installing it now.'
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  ## Prerequisites
  echo 'Installing xhyve, docker, docker-compose, and go'
  brew install xhyve docker docker-compose go

  ## Set up Go
  echo 'Setting up go directories'
  mkdir ~/.go

  ## Set up shell
  if [[ $SHELL == *"zsh"* ]]; then
    shellrc=$HOME/.zshrc
  else
    shellrc=$HOME/.bashrc
  fi
  echo 'export GOPATH=$HOME/.go' >> $shellrc
  source $shellrc

  ## Install docker-machine
  go get github.com/docker/machine
  cd $GOPATH/src/github.com/docker/machine
  make build
  make install

  ## Install docker-machine xhyve
  export GO15VENDOREXPERIMENT=1
  go get -u github.com/zchee/docker-machine-driver-xhyve
  cd $GOPATH/src/github.com/zchee/docker-machine-driver-xhyve
  make build
  make install
  sudo chown root:wheel $GOPATH/bin/docker-machine-driver-xhyve
  sudo chmod u+s $GOPATH/bin/docker-machine-driver-xhyve
}

case "$1" in
  install)
    install
    ;;
  mount)
    FOLDER=$2
    mount
    ;;
  *)
    echo $"Usage: $0 {setup|mount <path>}"
    exit 1
esac
