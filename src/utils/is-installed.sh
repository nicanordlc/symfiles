#!/bin/bash

__is_installed(){
    local LOG_FILE=${1:?"No file provided"}
    local app=${2:?"No app name provided"}
    local type=$3

    type_escaped="$(printf '%s' "$type" | sed 's;\([+-]\);\\\1;g')"

    app_formatted="$type_escaped :: $app ::"

    # tail to get last status in case multiple times introduced
    found_app="$(grep ^$app_formatted < $LOG_FILE | tail -n 1)"

    if [ -z "$found_app" ]; then
        return 1
    fi

    status="$(cut -d: -f5 <<<$found_app)"

    if [[ "$status" -eq 0 ]];then
        echo "✔ $app ($type)"
    else
        echo "✗ $app ($type) <----"
    fi
}

# If this file is running in terminal call the function `__is_installed`
# Otherwise just source it
if [ "$(basename "${0}")" = "is-installed.sh" ]
then
    __is_installed "${@}"
fi

