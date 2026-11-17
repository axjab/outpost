# Outpost — Human Project Brief

**Repository:** `axjab/outpost`  
**Description:** Deploy and manage persistent Debian outposts with independent identities, automated provisioning, and fleet health monitoring.  
**Targets:** Debian Trixie amd64; Linux first, Windows eventually without WSL or Distrobox. Terminal only.

## What we are building

A **public Debian OCI image** from which we can deploy multiple **persistent, independently enrolled Debian nodes**. A physical machine is a **site**; each container is an **outpost**. Outposts have separate hostnames, state, secrets/trust, networking and Host Doctor records, and report to **headquarters** (`hosts-of-embers`). They are managed as individual OS installations while still sharing the runtime's Linux kernel.

**This is an image project, not an `outpost` CLI.** Docker Engine exists; Kiri is our preferred Docker-API-compatible interface and must be tested. The user will manage image and container lifecycles using Kiri/Docker-compatible commands.

## Separate systems — do not conflate

| System | Job |
|---|---|
| **Outpost image** | Reusable, non-secret Debian environment and public dependencies. |
| **Outpost deployment/bootstrap** | Create a container instance and its durable storage, then start/enter it. **Not** `kindle.sh`. |
| **`kindle.sh`** (`hosts-of-embers`) | Provision/enroll any cold Debian OS — a new outpost **or a real server**. |
| **`hostdr`** (`host-doctor`) | Inspect **its own** OS. Existing CLI; **daemon not implemented**. |
| **Ansible** | Gradually turn useful Hostfile behaviors into idempotent OS configuration. |
| **HQ / hosts-of-embers** | Intended authoritative node inventory, enrollment and telemetry. |
| **`gopass`** | Secrets management; actual key trust/enrollment happens after instance creation. |

`core` is an existing **metapackage of public dependencies** from `apt.alj.cx`; review its installed dependency closure before publishing the public image. The current Dockerfile also installs `nb` using `dep/nb.sh` and imports Node.js 26 plus its bundled npm from the official `node:26-slim` image.

## Project rules

- **Public Git + public OCI image**, but **zero plaintext secrets**, unique identities, private inventory, vaults, or VPN state in source or image layers. Audit before publishing.
- No host-root mounts or outer-site administration in the baseline. Each Doctor measures its own node.
- Don't assume a container is a VM: persistence, `systemd`, privileged networking and VPN features must be tested.
- Do not rename `kindle.sh`, `hostdr`, or independent tools to fit the military theme. Preserve `NOMENCLATURE.md` and `docs/NOMENCLATURE.md`; reconcile drift deliberately.
- Follow `docs/bash-engineering-SKILL.md` when writing Bash.

## Our development loop

1. Agree on **one atomic, observable change**.
2. Assistant implements and sends a **ZIP containing only new/modified files**, preserving repository paths. It states real local test outcomes, not guesses.
3. **I** apply the patch, rebuild, run the exact proposed test, and send output.
4. Failure → fix the **same iteration**. Pass → **I commit**.
5. Update `JOURNAL.md`, then select the next small step. Repeat across image, deployment, Kindle, Doctor, and Ansible as needed.

No big-bang implementation. No claiming success before tests. No new Outpost CLI without an explicit change of scope.

## Current status / next action

- Project name **Outpost committed**; repository and image will be public.
- The current Dockerfile uses `node:26-slim` as a named build stage and keeps `debian:trixie-slim` as the final image. It copies `/usr/local/` from the Node.js stage, providing Node.js 26 and the npm bundled with that image.
- The image installs the `core` metapackage and `nb` from `dep/nb.sh`; `hx` remains the configured editor.
- **User-reported:** the integrated image builds and can be entered, and Node.js/npm are available. Exact runtime version output has not been recorded here.
- **Not implemented:** persistent outpost storage and image publication.

**Next gate:** review the image's build inputs and installed dependency closure, then publish the image as a separate task. Do not infer persistence from an ephemeral container test.

## Agent handoff

For the full operating contract, read [../AGENTS.md](../AGENTS.md); for actual progress and commits, read `../JOURNAL.md`. The **latest user request and real test output** override stale documentation.

## Home and shell defaults

- Shared Bash defaults live in `/etc/profile.d/default_bashrc.sh` and are loaded for login and interactive non-login shells.
- User settings live in `/home/a/.bashrc`; the starting template is `skel/.bashrc`, empty by default.
- An entrypoint copies `.bashrc`, `.bash_logout`, and an empty `.config` into a completely empty home only. Existing homes are left alone.
- The image version is stored in `/etc/outpost/version`, root-owned and mode 0444.
- See [HOME-SHELL.md](HOME-SHELL.md) for details and the test checklist.
