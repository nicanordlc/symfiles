#!/bin/bash

__pip(){
  case "$OS" in
      mac) pipx install "$@" ;;
      *) pip3 install --user "$@" ;;
  esac
}

# If this file is running in terminal call the function `__pip`
# Otherwise just source it
if [ "$(basename "${0}")" = "pip.sh" ]
then
  __pip "${@}"
fi

