# Outpost — TL;DR

Outpost is a small Debian 13 computer that runs inside a container. It gives you a familiar Linux environment on another machine without replacing that machine's operating system.

## What it is

- A Debian Trixie environment with a regular user, Bash, and command-line tools.
- Built from a versioned image and started with Docker or a compatible container manager.
- Designed to keep your home directory between container replacements.
- A reusable starting point. Each running Outpost gets its own home and should get its own identity and secrets.

## What it is not

- Not a virtual machine: it shares the Linux kernel provided by the container runtime.
- Not a way to administer the computer hosting it.
- Not yet a one-command installer or a fully provisioned server.

## What has changed

| Before | After |
|---|---|
| A plain Debian container | Debian plus the user's core tools, Node.js 26, nb, and Helix |
| No clear image version inside the container | The version is fixed in VERSION and baked into the image |
| No useful first-login status | Login can show Fastfetch, the image version, and whether configured kindling checks pass |
| Home setup depended on manual preparation | An empty home can be initialized from image defaults without overwriting an existing home |
| Image files were scattered across source folders | Image-installed files are grouped under rootfs/ |

## How to use it

- Start an existing deployment with its Compose file.
- Enter it with `docker compose exec outpost bash`.
- Build a new image with `./do/build`.
- The image version comes from the root VERSION file.

## Current limits

The image is a working foundation, not a finished managed-node system. A container build and real runtime test are still required for changes that have only passed shell-level checks. Deployment automation, enrollment, unique node identity, and fleet reporting are separate work.

For setup details and technical decisions, see README.md and docs/.
