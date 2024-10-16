#!/bin/bash -e
# shellcheck disable=1090,1117,2048
# vim: ts=4:sw=4

# Source script to source other scripts (;
# ===================================
. ./src/utils/source-if-exists.sh

# Source BEGINS
# ======================
sourceIfExists ./src/{functions,managers,utils}/*.sh

#####################
#                   #
# Prepare log files #
#                   #
#####################
BASE_PATH=$(__envsubst < ENV_HOME_SYM_CONFIG)
LOG_CONFIG_PATH=$(__envsubst < ENV_SYM_INSTALL_LOG)
LOG_CONFIG_PATH_STATUS=$(envsubst < ENV_SYM_INSTALL_LOG_STATUS)
mkdir -p "$BASE_PATH"
touch "$LOG_CONFIG_PATH"
touch "$LOG_CONFIG_PATH_STATUS"

############
#          #
# Consants #
#          #
############
TEMP_APP_CSV=$(mktemp)
TEMP_SUDO_PASSWORD="$BASE_PATH/sudo-password"
TEMP_SUDO_PASSWORD_TIMER="$((60 * 30))"
INSTALL_MANAGER_TYPES=(
    a
    f
    g
    gem
    m
    node
    pip
)

#################
#               #
# Trapped files #
#               #
#################
trap '{ rm -rf $TEMP_APP_CSV ; }' SIGINT SIGTERM EXIT
trap '{ __delete_password_temp ; }' SIGINT SIGTERM EXIT
__delete_password_temp(){
    (
        sleep "$TEMP_SUDO_PASSWORD_TIMER"
        rm -rf "$TEMP_SUDO_PASSWORD"
    ) &
}

#############
#           #
# Functions #
#           #
#############

__install() {
    local APPS_CSV INSTALL_MANAGER INSTALL_MANAGER_TYPE TYPE NAME STATE DESCRIPTION
    APPS_CSV=$1

    # Strip comments and empty lines
    sed -e '/^#/d' -e '/^$/d' "$APPS_CSV" >"$TEMP_APP_CSV"

    IFS=,
    while read -rs TYPE NAME STATE DESCRIPTION; do
        INSTALL_MANAGER_TYPE=$TYPE

        # Format `type` for logging purposes
        [[ "$TYPE" ]] &&
            TYPE="- $TYPE -"

        # If the app is installed or turned off do nothing
        __is_installed "$LOG_CONFIG_PATH_STATUS" "$NAME" "$TYPE" ||
            [[ "$STATE" == "off" ]] &&
            continue

        if [ -n "$INSTALL_MANAGER_TYPE" ] &&
            ! __includes \
                "${INSTALL_MANAGER_TYPES[*]}" \
                "$INSTALL_MANAGER_TYPE"
        then
            echo "✗ $NAME | Wrong installer type ( $INSTALL_MANAGER_TYPE )"
            continue
        fi

        case $INSTALL_MANAGER_TYPE in
        a) INSTALL_MANAGER=__aur ;;
        f) INSTALL_MANAGER=__function ;;
        m) INSTALL_MANAGER=__make_pkg ;;
        g) INSTALL_MANAGER=__go_pkg ;;
        "") INSTALL_MANAGER=__package_manager ;;
        gem) INSTALL_MANAGER=__gem ;;
        pip) INSTALL_MANAGER=__pip ;;
        node) INSTALL_MANAGER=__node ;;
        esac

        # Format `description` for logging purposes
        [[ "$DESCRIPTION" ]] &&
            DESCRIPTION="\n\t$DESCRIPTION"

        # Mapper's header (Log)
        echo -e ":: $NAME $TYPE ::$DESCRIPTION" | tee -a "$LOG_CONFIG_PATH"

        # EXECUTE INSTALL
        $INSTALL_MANAGER "$NAME" | tee -a "$LOG_CONFIG_PATH" 2>&1

        # Status (Log)
        echo -e "$TYPE :: $NAME :: ${PIPESTATUS[0]}\n" >> "$LOG_CONFIG_PATH_STATUS"
    done <"$TEMP_APP_CSV"
}

__set_zsh() {
    local IS_ZSH PASS

    IS_ZSH=$(
        if [ "$(basename "$SHELL")" == "zsh" ]; then
            echo "true"
        fi
    )

    # terminate this function if you already have zsh or it is not installed
    if [ -n "$IS_ZSH" ] || ! command -v zsh &>/dev/null; then
        return 0
    fi

    # set zsh as default shell
    if ! [ -f "$TEMP_SUDO_PASSWORD" ]; then
        TEMP_SUDO_PASSWORD=$(mktemp)
        read -rsp "Sudo password: " PASS
        echo "$PASS" > "$TEMP_SUDO_PASSWORD"
    fi

    chsh -s "$(grep "/zsh$" /etc/shells | tail -1)" <"$TEMP_SUDO_PASSWORD"
}

__prompt_password() {
    local PROMPT_PASSWORD

    if [ "${PASSWORD:-}" ]; then
        echo "$PASSWORD" >"$TEMP_SUDO_PASSWORD"
    elif [ -f "$TEMP_SUDO_PASSWORD" ] && [ -n "$(cat "$TEMP_SUDO_PASSWORD")" ]; then
        return 0
    else
        read -rsp "Type sudo password for later use 🔒: " PROMPT_PASSWORD
        echo
        echo
        echo "$PROMPT_PASSWORD" >"$TEMP_SUDO_PASSWORD"
    fi
}

#########
#       #
# Begin #
#       #
#########

main() {
    local OS CSV_SUFFIX DEFAULT_APPS_FILES APPS_FILES APPS_FILE

    # This is to catch the password for later use if needed ;)
    __prompt_password

    echo "[Installing]..."
    echo

    # prepare mac variables
    case "$(uname -s)" in
    [Dd]arwin)
        export OS="mac"
        export CSV_SUFFIX="-mac"
        ;;
    *) echo "" ;;
    esac

    DEFAULT_APPS_FILES=(
        "./src/apps-common.csv"
        "./src/apps${CSV_SUFFIX}.csv"
    )

    APPS_FILES=("${@:-${DEFAULT_APPS_FILES[*]}}")

    for APPS_FILE in ${APPS_FILES[*]}; do
        if ! [ -f "$APPS_FILE" ]; then
            echo "---> $APPS_FILE -- This file does not exists, just in case (˘_˘٥)"
            continue
        fi

        __install "$APPS_FILE"

        echo -e "\n$APPS_FILE -- Finished...\n\t(ﾉ^_^)ﾉ"
        echo
    done

    # this is needs to be here if you're using zsh
    __set_zsh
}

main "$@"
