#!/usr/bin/env sh

set -euo pipefail

build_deps() {
  os=''
  check_os os
  
  arch=''
  check_architecture arch
  
  config="${1-release}"
  check_config $config config
  
  # where are we?
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  
  # add utils scripts for our platform to this file
  utils_folder="$SCRIPT_DIR/utils.$os"
  for util in "$utils_folder"/*
  do
    source "$util"
  done
  
  # add all dependency script files for our platform to this file
  deps_folder="$SCRIPT_DIR/deps.$os"
  dependencies=()
  for dependency in "$deps_folder"/*
  do
    source "$dependency"
    dependencies+=("$(basename "$dependency")")
  done
  
  mkdir -p "build_temp_$os-$arch-$config"
  cd "build_temp_$os-$arch-$config"
  for dependency in "${dependencies[@]}"
  do
    # set up the dependency
    setup_func="${dependency}_setup"
    $setup_func
    
    # if we have a patch, patch the dependency
    patch_func="${dependency}_patch"
    $patch_func
    
    # build the dependency
    build_func="${dependency}_build"
    $build_func
  done
  cd ..
  
  mkdir -p "ares-deps"
  for dependency in "${dependencies[@]}"
  do
    # install the dependency
    install_func="${dependency}_install"
    $install_func
  done
  cd ..
  echo "artifactName=ares-deps-$os-$arch" >> $GITHUB_OUTPUT
}

check_os() {
  if [ "$(uname)" == "Darwin" ]; then
    eval "$1='macos'"
  else
    eval "$1='windows'"
  fi
}

check_architecture() {
  if [ "$(uname)" == "Darwin" ]; then
    eval "$1='universal'"
  else
    local unametest=$(uname -a)
    echo $unametest
    local unameout=$(uname -p)
    eval "$1=$unameout"
  fi
}

check_config() {
  if [[ $1 == "debug" ]]; then
    eval "$2='Debug'"
  elif [[ $1 == 'release' ]]; then
    eval "$2='RelWithDebInfo"
  elif [[ $1 == 'optimized' ]]; then
    eval "$2='MinSizeRel'"
  else
    eval "$2='RelWithDebInfo'"
  fi
}

build_deps "${@}"
