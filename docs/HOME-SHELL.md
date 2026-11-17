# Home and Bash startup

Outpost keeps shared shell defaults in the image and user settings in the home directory.

## Files

- `default_bashrc.sh` is installed as `/etc/profile.d/default_bashrc.sh`.
- Debian's `/etc/profile` loads that file for login shells.
- `/etc/bash.bashrc` also loads it for interactive non-login Bash shells.
- `etc/profile.d/outpost-profile.sh` sources `$HOME/.bashrc` for login shells.
- Bash itself sources `$HOME/.bashrc` for interactive non-login shells.
- `skel/.bashrc` is the user-owned starting template. It is empty by default; edit it to seed new homes.
- `default_bash_logout.sh` is copied to `/home/a/.bash_logout`.
- The image creates an empty `.config` directory in its skeleton.
- `/etc/outpost/version` contains the build's `OUTPOST_VERSION` and is owned by root with mode 0444.

The image starts with an empty `/home/a`. On container startup, the entrypoint copies the skeleton into the home only when it contains no entries. It does not merge defaults into a partially populated home and does not overwrite existing user files.

The entrypoint runs as user `a`; therefore an empty bind-mounted home must be writable by that user. Each outpost should have its own home volume rather than sharing one between instances.

## Version file limitation

Mode 0444 prevents the normal Outpost user from writing the version file. It is not a kernel immutable attribute: root inside a container can change permissions and replace it. The immutable flag is not a portable guarantee on Docker overlay filesystems. The authoritative version remains the value baked into the image at build time.

## Test checklist

Build:

```bash
OUTPOST_VERSION=0.2.0 ./do/build
```

Run with a fresh empty home:

```bash
home=$(mktemp -d)
docker run --rm -it -v "$home:/home/a" ghcr.io/axjab/outpost:0.2.0
```

Inside the container, check:

- [ ] `cat /etc/outpost/version` prints `0.2.0`.
- [ ] `stat -c '%U:%G %a' /etc/outpost/version` reports `root:root 444`.
- [ ] As user `a`, `test ! -w /etc/outpost/version` succeeds.
- [ ] `/home/a/.bashrc` exists and is empty.
- [ ] `/home/a/.bash_logout` exists.
- [ ] `/home/a/.config` exists and is empty.
- [ ] The login shell loads the shared prompt and aliases from `default_bashrc.sh`.
- [ ] A nested interactive non-login Bash shell also loads the shared prompt and aliases.
- [ ] Add a temporary export to `/home/a/.bashrc`; confirm it is visible in both login and non-login interactive shells.
- [ ] Exit the shell and confirm the default `.bash_logout` runs without errors.

Test an existing home:

- [ ] Put a sentinel file in a second host directory and mount it at `/home/a`.
- [ ] Start the container; confirm the sentinel remains and no skeleton files are copied over it.

The automated entrypoint test can be run with:

```bash
bash tests/test-outpost-entrypoint.sh
```

A Docker build and runtime test are still required; shell-level tests alone do not verify Debian's actual startup behavior.
