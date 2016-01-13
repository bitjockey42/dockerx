#!/usr/bin/env sh

install() {
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

mount() {
  ## Set up NFS share on HOST machine
  sudo echo "$current_path -mapall=$(id -u)" >> /etc/exports
  sudo nfsd enable
  sudo nfsd start

  ## Load docker ENV vars
  eval $(docker-machine env dev)

  ## Create NFS folder in tinycore
  docker-machine ssh dev 'mkdir -p ~/mounts/' "$(basename current_path)"

  ## Mount in tinycore
  mount_cmd='sudo mount -o nolock -t nfs'
  host_nfs_addr="192.168.64.1:$current_path"
  guest_nfs_addr='~/mounts/$(basename current_path)'
  docker-machine ssh dev $mount_cmd $host_nfs_addr $guest_nfs_addr

  ## NOTE: 192.168.64.1 is the IP of the host machine
  ## Then, in docker-compose.yml, the shared folder on tinycorelinux will be what you want to use
  ##
  ##  volumes:
  ##    - /home/docker/shared:/answerqueue
}

case "$1" in
  install)
    install
    ;;
  mount)
    current_path="cd $2; $(pwd)"
    mount
    ;;
  *)
    echo $"Usage: $0 {install|mount <path>}"
    exit 1
esac
