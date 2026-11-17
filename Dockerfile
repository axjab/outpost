# OUTPOST

# Node.js source
FROM node:26-slim AS node

# Operating system
FROM debian:trixie-slim

ENV EDITOR=hx
ENV VISUAL=hx

# Import Node.js and npm, then install the image-owned filesystem and fixed version.
COPY --from=node /usr/local/ /usr/local/
COPY rootfs/ /
COPY VERSION /usr/share/outpost/version

# Create the container user and set permissions on image-owned files.
RUN set -eu; \
    useradd --create-home --user-group --shell /bin/bash a; \
    chmod 0755 /usr/local/bin/outpost-entrypoint /usr/local/bin/outpost-kindling-status; \
    install -d -m 0755 /etc/outpost/skel/.config; \
    chmod 0444 /usr/share/outpost/version

# Install system tools, configure the APT repository, and install core.
# Keep APT indexes and package installation in this layer so cleanup reduces image size.
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
    rm -rf /var/lib/apt/lists/*

# Install nb and remove its temporary installer.
RUN set -eu; \
    /bin/sh /tmp/nb-install.sh; \
    rm -f /tmp/nb-install.sh

USER a
WORKDIR /home/a

ENTRYPOINT ["/usr/local/bin/outpost-entrypoint"]
CMD ["/bin/bash", "--login"]
