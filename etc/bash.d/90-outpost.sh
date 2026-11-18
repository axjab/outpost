# Show Outpost information once per container entry.
case $- in
    *i*) ;;
    *) return ;;
esac

[ -t 1 ] || return
if [[ -v OUTPOST_SHELL_INFO_SHOWN ]]; then return; fi

export OUTPOST_SHELL_INFO_SHOWN=1

if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

if [ -r /usr/share/outpost/version ]; then
    printf 'Outpost version: %s\n' "$(< /usr/share/outpost/version)"
fi

if command -v outpost-kindling-status >/dev/null 2>&1; then
    if outpost-kindling-status --quiet; then
        printf 'Kindling: Kindled\n'
    else
        printf 'Kindling: Unkindled\n'
    fi
fi
