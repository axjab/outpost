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


## Latest decisions — 2026-11-16

- Machine information is not collected interactively: pretty hostname `Outpost: <system hostname>`, no location, tag `virtual`, default user `a`. First-time-install detection is deferred.
- A reusable image must not contain a read-only marker claiming that every instance is already kindled. If implemented later, local completion state belongs under per-instance persistent `/var/lib/outpost/`; HQ enrollment and local completion state remain distinct. No state mechanism is implemented yet.
- Fastfetch comes from the existing `core` metapackage and runs from `/etc/profile.d/outpost.sh` in interactive login shells. The hook is image-owned and does not depend on `/home/a`, which may be mounted.


## Login status

Interactive login shells show Fastfetch, the baked Outpost version, and whether every configured kindling policy passes. The hook lives in `/etc/profile.d/outpost.sh`, not in the mountable home directory. Policies live in `/etc/outpost/kindling.d/*.check`; adding or removing a check changes the required policy set. No configured policies or any failed/unverifiable check means Unkindled. Fastfetch comes from `core`, not a separate package install.
