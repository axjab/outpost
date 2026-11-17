# Show Outpost status in interactive login shells.
case $- in
    *i*) ;;
    *) return ;;
esac

[ -t 1 ] || return
if [ -n "$OUTPOST_LOGIN_SHOWN" ]; then return; fi

export OUTPOST_LOGIN_SHOWN=1

fastfetch
printf 'Outpost version: %s\n' "$(cat /usr/share/outpost/version)"

if /usr/local/bin/outpost-kindling-status --quiet; then
    printf 'Kindling: Kindled\n'
else
    printf 'Kindling: Unkindled\n'
fi
