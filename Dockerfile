
# OUTPOST

# Node.js source
FROM node:26-slim AS node
# Operating system
FROM debian:trixie-slim

ARG OUTPOST_VERSION=dev
LABEL org.opencontainers.image.version="${OUTPOST_VERSION}"

ENV EDITOR=hx
ENV VISUAL=hx

# Import Node.js and npm from official image
COPY --from=node /usr/local/ /usr/local/

COPY dep/nb.sh /tmp/nb-install.sh
COPY bin/outpost-kindling-status /tmp/outpost-kindling-status
COPY lib/outpost-kindling/common.sh /tmp/outpost-kindling-common.sh
COPY etc/outpost/kindling.d/ /tmp/kindling.d/

RUN useradd --create-home --user-group --shell /bin/bash a; \
    install -D -m 0755 /tmp/outpost-kindling-status /usr/local/bin/outpost-kindling-status; \
    install -D -m 0644 /tmp/outpost-kindling-common.sh /usr/lib/outpost-kindling/common.sh; \
    install -d -m 0755 /etc/outpost/kindling.d; \
    install -m 0644 /tmp/kindling.d/*.check /etc/outpost/kindling.d/; \
    printf '%s\\n' "$OUTPOST_VERSION" > /etc/outpost/version; \
    rm -rf /tmp/outpost-kindling-status /tmp/outpost-kindling-common.sh /tmp/kindling.d

RUN set -eu; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl sudo; \
    printf '%s\n' 'a ALL=(root) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get' \
        > /etc/sudoers.d/outpost-apt; \
    chmod 0440 /etc/sudoers.d/outpost-apt; \
    installer=$(mktemp); \
    curl -q --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
        --connect-timeout 10 --max-time 60 \
        --output "$installer" https://apt.alj.cx/install; \
    printf '%s  %s\n' '87b6108f3f8ff8d385213fecfe1c4fbb1c3632aa0699f489d5a1a7573f53de6e' "$installer" | sha256sum -c -; \
    chmod 0644 "$installer"; \
    printf '%s\n' 'a ALL=(root) NOPASSWD: /usr/bin/flock -w 30 /run/pkg-cli-install.lock /bin/sh -s -- /tmp/pkg-cli-bootstrap.*' \
        > /etc/sudoers.d/outpost-bootstrap; \
    chmod 0440 /etc/sudoers.d/outpost-bootstrap; \
    visudo -cf /etc/sudoers; \
    runuser -u a -- /bin/sh "$installer"; \
    rm -f "$installer" /etc/sudoers.d/outpost-bootstrap /run/pkg-cli-install.lock; \
    apt-get install -y --no-install-recommends core; \
    /bin/sh /tmp/nb-install.sh; \
    rm -f /tmp/nb-install.sh; \
    printf '%s\n' \
        '' \
        '# Show Outpost status once per interactive terminal session.' \
        'if [[ $- == *i* && -t 1 && -z ${OUTPOST_LOGIN_SHOWN:-} ]]; then' \
        '    export OUTPOST_LOGIN_SHOWN=1' \
        '    fastfetch' \
        '    printf "Outpost version: %s\\n" "$(cat /etc/outpost/version)"' \
        '    if /usr/local/bin/outpost-kindling-status --quiet; then' \
        '        printf "Kindling: Kindled\\n"' \
        '    else' \
        '        printf "Kindling: Unkindled\\n"' \
        '    fi' \
        'fi' \
        >> /home/a/.bashrc; \
    rm -rf /var/lib/apt/lists/*

USER a
WORKDIR /home/a

CMD ["/bin/bash"]
