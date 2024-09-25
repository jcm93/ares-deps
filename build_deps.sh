#!/usr/bin/env sh

build_deps() {
  os=''
  check_os os
  
  arch=''
  check_architecture arch
  
  # temp
  config='release'
  
  # where are we?
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  
  # add all dependency script files for our platform to this file
  deps_folder="$SCRIPT_DIR/deps.$os"
  dependencies=()
  for entry in "$deps_folder"/*
  do
    source "$entry"
    dependencies+=("$(basename "$entry")")
  done
  
  mkdir build_temp
  cd build_temp
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
  
  mkdir "ares-deps-$os-$arch"
  for dependency in "${dependencies[@]}"
  do
    # install the dependency
    install_func="${dependency}_install"
    $install_func
  done
  cd ..
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
    eval "$1='todo'"
  fi
}

build_deps
