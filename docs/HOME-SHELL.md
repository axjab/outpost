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
- `VERSION` is the single version source in the repository. The image copies it to `/usr/share/outpost/version`, owned by root with mode 0444. It is not a build argument or runtime setting.

The image starts with an empty `/home/a`. On container startup, the entrypoint copies the skeleton into the home only when it contains no entries. It does not merge defaults into a partially populated home and does not overwrite existing user files.

The entrypoint runs as user `a`; therefore an empty bind-mounted home must be writable by that user. Each outpost should have its own home volume rather than sharing one between instances.

## Version file limitation

The version is fixed by the repository's `VERSION` file. `do/build` reads that file for the image tag; the Dockerfile copies the same file into `/usr/share/outpost/version`. There is no `OUTPOST_VERSION` build argument or environment override. Mode 0444 prevents ordinary writes by user `a`; container root can still replace files in its writable layer.

## Test checklist

Build:

```bash
./do/build
```

Run with a fresh empty home:

```bash
home=$(mktemp -d)
docker run --rm -it -v "$home:/home/a" ghcr.io/axjab/outpost:$(cat VERSION)
```

Inside the container, check:

- [ ] `cat /usr/share/outpost/version` matches the repository's `VERSION` file.
- [ ] `stat -c '%U:%G %a' /usr/share/outpost/version` reports `root:root 444`.
- [ ] As user `a`, `test ! -w /usr/share/outpost/version` succeeds.
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
