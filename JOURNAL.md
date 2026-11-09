# Project Journal — Outpost

**Updated:** 2026-11-09  
**Status:** Name committed; image-only scope confirmed; bare Debian Kiri smoke test still unverified.  
**Repository:** `axjab/outpost` (name committed by user)  
**Description:** Deploy and manage persistent Debian outposts with independent identities, automated provisioning, and fleet health monitoring.  
**Scope:** Linux-first, amd64, terminal-only, Docker API/Kiri, Debian Trixie; Windows later with no WSL or Distrobox.

## Orientation for the next session

- A **site** is the outer computer. An **outpost** is one independent Debian OS instance installed at that site. A site can host many outposts; each has its own hostname, identity, state, connectivity, and Host Doctor reporting to HQ.
- Outposts share the Linux kernel of the runtime/VM; they are independent **managed nodes**, not necessarily independent kernel environments.
- There are **two distinct workflows**: (1) host-side deployment/installation of an outpost; (2) `kindle.sh` provisioning/enrollment **of a cold OS**. The latter must also work on a real Debian server, without a container.
- `hostdr` is a separate existing CLI; **its daemon does not exist yet**. Each physical host or outpost running Host Doctor has an independent health record.
- `hosts-of-embers` is the desired single inventory/enrollment source of truth. Ansible may replace the old Hostfile's configuration operations, but should not create another authoritative inventory.
- Public Git repository and public OCI image are committed targets. `core` is a metapackage of public dependencies; audit image layers and provisioning output for inadvertent secrets before release. `gopass` holds secrets; no secrets/unique identities/private inventory in sources or image layers.
- Existing scripts retain their independent names (`kindle.sh`, `hostdr`, `core`). Full terminology is in `docs/NOMENCLATURE.md`.

## Architecture

```text
                      Headquarters (hosts-of-embers)
                 inventory / enrollment / Doctor telemetry
                               ^          ^
                  independent OS node records
                               |          |
         SITE A (Linux)                       SITE B (Linux or Windows+VM)
          Docker/Kiri                           container substrate
            |- Outpost alpha (Debian)            `- Outpost gamma (Debian)
            |    |- independent identity            |- independent identity
            |    |- persistent state                |- persistent state
            |    |- kindle when cold                |- kindle when cold
            |    `- hostdr (later daemon)           `- hostdr (later daemon)
            `- Outpost beta (Debian)
                 |- independent identity
                 `- independent hostdr

         Future physical Debian server
            `- kindle -> provision -> hostdr -> HQ

outpost deployment != kindle.sh != hostdr/Host Doctor daemon
```

The site's kernel/runtime capabilities constrain an outpost's ability to run systemd, network management, firewalls, Tailscale or other OS services. The outpost does **not** implicitly mount host-root, use the Docker socket, execute `nsenter`, or inspect/control the site. Any later cross-site administration feature needs a separate explicit decision.

## Existing components examined

### Cold host: `kindle.sh` (`hosts-of-embers`)

- Source: user attachment `Pasted text(20261109-203529).txt`; partly implemented.
- Main flow: install dependencies -> record initialization -> set architecture -> run diagnostic checks. Intended end-to-end flow: Connect -> Dependencies -> Identity -> Enrollment -> Provisioning -> Inspection.
- Detects `jq`, `git`, `gpg`, `gopass`; uses APT then re-exec. Potential indefinite loop if install doesn't resolve missing dependency; no reliable fatal stop (`set -e`/`-u` commented out).
- Uses `hostnamectl` JSON and `/etc/machine-info`; records initialization timestamp before verification is complete.
- Checks hostname, location, tags, user, GPG, SSH, Tailscale, GitHub, Git server, configuration, credentials and vault.
- Secret exposure: `gopass gitlab/token` used as a success test may print plaintext secret. Replace with non-disclosing verification before running automatically.
- `kindle.sh` remains **in its own project** and is not renamed to fit Outpost.

### Health: `hostdr` (`host-doctor`)

- Source: user attachment `hostdr(1)`; CLI version 1.0.0. Standalone Bash/JQ health check with formatted color-dot output and JSON.
- Checks OS, network/DNS/HTTPS/public IP, Mullvad/geolocation, firewall/SSH, unattended upgrades, services/timers, disks/mounts.
- Report includes timestamp, hostname, checks, and summary. Exit: 0 healthy/warnings, 1 unhealthy, 2 CLI/dependency error.
- Hard-coded checks/policies currently include `REQUIRE_MULLVAD=true`, `REQUIRED_SERVICES=(ssh)` and `MONITORED_MOUNTS=(/)`; different OS roles need proper applicability/profiles.
- **Daemon missing:** no scheduled checks, store-and-forward, HQ transport, or host enrollment integration yet.
- A Doctor instance examines its **own OS**; a physical site's Doctor is not an outpost's Doctor.

### Existing Hostfile (inline in user message)

- Prototype DSL for inventory, aliases and host services and operations `Sync`, `Copy`, `Link`, `Process`.
- Useful source of desired state for dotfile links, templating, file sync and configuration; not an Ansible playbook.
- Source of truth should move to `hosts-of-embers` API; no new independent static host roster.
- Avoid duplicating functionality already delivered by the `core` APT package, such as executables in `/usr/bin`.
- Desktop-specific configuration is conditional and should not be installed indiscriminately inside minimal outposts.

### Dependencies to inspect when required

- `core` APT payload, dependencies, maintainer scripts, configuration and daemon behavior.
- Kiri version/capabilities; Docker Engine already installed on the user's Linux host, Kiri being installed separately.
- HQ enrollment and Doctor telemetry API contract.
- Container capabilities for network/SSH, GPG, init, systemd, Tailscale and service management.
- Windows VM runtime strategy without WSL. Never assume native Windows can execute Linux containers directly.

**Prior checks:** Bash syntax checks were reported as passing. No integration tests or host rebuild results have been supplied.

## Scope correction (2026-11-09)

- **Outpost is an OCI image project, not a runtime management CLI.** No `outpost create`, `enter`, or `inspect` commands are planned. Use `kiri` / Docker-compatible commands for lifecycle operations.
- Any future installation/launcher automation must be proposed separately and should not be assumed to be a project CLI.
- `core` is a metapackage of public dependencies, not an application-specific secret bundle. Do not bake `gopass` vaults or credentials into image layers.
- Current atomic test: build bare `debian:trixie-slim` and enter it with Kiri. Do not add persistence until the test passes.

## Frozen boundaries

| Workstream | Owns | Does NOT own |
|---|---|---|
| **Debian image** | Reproducible, disposable Debian filesystem, installed dependencies, audited `core` | Unique host identity, gopass secrets, vault content, VPN state |
| **Outpost deployment/bootstrap (future, separate from image)** | Acquire image, allocate per-instance data, create/start/stop/enter/recreate, backend integration | Cold-OS enrollment; automatic inspection of outer site |
| **`kindle.sh`** | Cold Debian provisioning, initial node identity/trust, enrollment, diagnostics | Creating outposts or managing Docker/Kiri |
| **Host Doctor CLI** | Inspect and report the current OS | Inspect a parent site from inside its outpost |
| **Host Doctor daemon** | Schedule health checks, persist failures, forward node telemetry to HQ | Provision hosts or create container instances |
| **Ansible** | Declarative idempotent configuration/templating for real and virtual Debian | Maintaining a competing authoritative inventory |

## Iteration protocol (non-negotiable)

1. Identify **one atomic behavior change** from the latest tested baseline.
2. Describe its paths, acceptance test, rollback and scope.
3. Assistant delivers one ZIP containing **only new or changed files**, preserving exact project paths; no unrelated code.
4. User applies the patch, rebuilds/tests the relevant image/scripts (curl, Ansible, `hostdr`, etc.).
5. Fix failures within the same iteration until it passes.
6. User commits; capture commit and test outcome in this journal.
7. Repeat, incrementally advancing image, outpost installer, cold-host kindle, Host Doctor daemon, and Ansible.

Never claim tests passed without actual results. Keep machine secrets and enrolled state out of test ZIPs and image layers.

## Roadmap

| Track | Next checkpoint | Later work |
|---|---|---|
| Image | Kiri boots bare Debian Trixie amd64 | Image build reproducibility -> APT/core audit -> non-secret dependencies -> services as feasible |
| Outpost installer | Design minimal create/enter lifecycle with persistent volume | Multiple instances -> upgrades -> Linux one-command installer -> Windows VM backend |
| Kindle | Stop dependency-install recursion and eliminate plaintext vault test | Idempotent stages, unique identities, enrollment, shared physical/virtual profiles |
| Host Doctor | Verify `hostdr` against bare Debian | Applicability profiles -> stable JSON -> daemon -> durable queue -> HQ reporting |
| Ansible | Migrate one meaningful Hostfile operation | Roles -> inventory from hosts-of-embers API -> drift checks |
| Connectivity | Decide per-node SSH/GPG/VPN storage and trust bootstrap | Dedicated VPN identities, peer SSH, remote HQ, no inherited credentials |

**Persistence warning:** a persistent home/volume does not make the whole root filesystem persistent after recreating a container from an image. We must explicitly decide what state survives and test this before treating outposts as durable Debian machines.

## Decision register

| ID | Decision | State |
|---|---|---|
| D-001 | OCI/Docker API, Kiri for initial Linux runtime | Planned; needs tests |
| D-002 | Linux first, Windows later; no Distrobox or WSL | Accepted |
| D-003 | No secret/host identity in Git, OCI image layers or build logs | Accepted |
| D-004 | Separate persistent state and replaceable image | Accepted concept; exact mounts undecided |
| D-005 | Outpost deployment and `kindle.sh` cold-OS provisioning are distinct | Accepted |
| D-006 | One Doctor per OS/node; outpost != site | Accepted |
| D-007 | Baseline doesn't administer/inspect outer site from within outpost | Accepted |
| D-008 | Public repo and public image, contingent on audit | Accepted target; NOT released |
| D-009 | `axjab/outpost`, military-oriented vocabulary | **Accepted 2026-11-09** |
| D-010 | Ansible may replace Hostfile operations selectively | Provisional |
| D-011 | Systemd/init and full networking need experiment | Open |
| D-012 | Audit `core` package, scripts, image history before public release | Pending |
| D-013 | Existing other-project commands retain their names | Accepted |

## Iteration log

### Iteration 0 — Source discovery (2026-11-09)

- Received `kindle.sh`, `hostdr`, and Hostfile; `core` package is described but not yet examined.
- Corrected the scope so deployment, cold-OS kindling, and per-OS health reporting remain separate.
- Identified `kindle.sh` restart-loop/secret-output hazards; daemon currently absent.

### Iteration 0b — Naming and release design (2026-11-09)

- User rejected `consulate`, accepted `outpost` with military-oriented terminology.
- Existing projects use `outpost` CLIs for remote container tooling; accepted as a namespace collision risk, not a reason to rename again.
- Planned public source/public image with mandatory checks; not yet published.
- Only documentation changes in this iteration: `PROJECT-JOURNAL.md` and `docs/NOMENCLATURE.md`.

### Iteration 1 — Bare Debian image (prepared, NOT verified)

- Previous ZIP: `hearth-iteration-01.zip` (temporary earlier name), containing **only** `Dockerfile`.
- Base: `debian:trixie-slim`; command: `/bin/bash`. No persistence, enrollment, services or host privileges in that baseline.
- Test requested (after extracting file to current repository):

  ```bash
  kiri build -t outpost:dev .
  kiri run --rm -it outpost:dev
  cat /etc/os-release
  dpkg --print-architecture
  exit
  ```

- Success criteria: Debian Trixie, architecture amd64, interactive terminal, clean exit.
- `--rm` is deliberately a **disposable smoke test**, not a persistence implementation.
- **No Kiri result, test output, commit hash or deployment evidence received yet.**

## Next handoff

1. Apply the documentation-only update if approved.
2. Run/confirm the bare Debian Kiri smoke test. Keep Docker Engine intact.
3. On a pass, implement the smallest persistent named-outpost lifecycle change; later introduce `core` and Kindle only after successful tests.
4. For each iteration, update this journal with *actual* results and the commit hash, not intended outcomes.
