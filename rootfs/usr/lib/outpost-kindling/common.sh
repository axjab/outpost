#!/usr/bin/env bash

machine_info_value() {
    local wanted=$1 line value

    [[ -r /etc/machine-info ]] || return 1

    while IFS= read -r line; do
        case "$line" in
            "$wanted="*)
                value=${line#*=}
                if [[ $value == \"*\" ]]; then
                    value=${value:1:${#value}-2}
                fi
                printf '%s' "$value"
                return 0
                ;;
        esac
    done < /etc/machine-info

    return 1
}

has_ssh_host() {
    local wanted=$1
    [[ -r $HOME/.ssh/config ]] || return 1
    awk -v wanted="$wanted" '
        tolower($1) == "host" {
            for (i = 2; i <= NF; i++) {
                if (tolower($i) == tolower(wanted)) found = 1
            }
        }
        END { exit !found }
    ' "$HOME/.ssh/config"
}
