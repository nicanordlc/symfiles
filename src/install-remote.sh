#!/bin/bash
set -Eeuo pipefail

main() {
  local $GIT_USERNAME
  local $GIT_REPO

  # git dependency (install git ?)
  xcode-select install

  # make sure projects directory is ready
  mkdir -p "$HOME/projects"

  # clone dotfiles and cd to it
  cd "$HOME/projects/"
  git clone "https://github.com/$GIT_USERNAME/$GIT_REPO" dotfiles

  # spread dotfiles configurations on the system
  make install
}

main "$@"
