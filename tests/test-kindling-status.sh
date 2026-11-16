#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)/bin/outpost-kindling-status"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -m 700 "$tmp/policies" "$tmp/empty"
cat > "$tmp/policies/10-pass.check" <<'POLICY'
#!/usr/bin/env bash
exit 0
POLICY

if bash "$SCRIPT" --policy-dir "$tmp/policies" --quiet 2>/dev/null; then
    :
else
    printf 'Expected passing policy set to be kindled.\n' >&2
    exit 1
fi

cat > "$tmp/policies/20-fail.check" <<'POLICY'
#!/usr/bin/env bash
exit 1
POLICY
if "$SCRIPT" --policy-dir "$tmp/policies" --quiet >/dev/null 2>&1; then
    printf 'Expected one failed policy to make the host unkindled.\n' >&2
    exit 1
fi
rm "$tmp/policies/20-fail.check"

if "$SCRIPT" --policy-dir "$tmp/empty" --quiet >/dev/null 2>&1; then
    printf 'Expected an empty policy set to be unkindled.\n' >&2
    exit 1
fi

chmod 777 "$tmp/policies"
if "$SCRIPT" --policy-dir "$tmp/policies" --quiet >/dev/null 2>&1; then
    printf 'Expected a writable policy directory to be rejected.\n' >&2
    exit 1
fi

printf 'Kindling status tests passed.\n'
