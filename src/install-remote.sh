#!/bin/bash
set -Eeuo pipefail

main() {
  local $GIT_USERNAME
  local $GIT_REPO

  # make sure projects directory is ready
  mkdir -p "$HOME/projects"

  # clone dotfiles and cd to it
  cd "$HOME/projects/"
  git clone "https://github.com/$GIT_USERNAME/$GIT_REPO" dotfiles || true
  cd dotfiles

  # spread dotfiles configurations on the system
  make link
}

main "$@"

