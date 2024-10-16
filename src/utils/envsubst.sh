#!/bin/bash -e

__envsubst() {
  while read line; do
    line=$(echo "$line" | sed 's;"\;\\";g;') eval echo "$line"
  done
}

# If this file is on the terminal $PATH's just run the function `__envsubst`
# Otherwise just source it and run
if [ "$(basename "$0")" = "envsubst.sh" ]; then
    __envsubst "${@}"
fi

