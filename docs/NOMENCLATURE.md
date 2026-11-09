# Outpost — Naming and vocabulary

**Status:** Accepted, 2026-11-09  
**Repository:** `axjab/outpost` (planned)  
**Image:** `ghcr.io/axjab/outpost` (planned; not published)  
**CLI:** No Outpost-specific CLI planned; use Kiri / Docker-compatible CLI  
**Repository description:** Deploy and manage persistent Debian outposts with independent identities, automated provisioning, and fleet health monitoring.

## The analogy

A physical computer is a **site** or **territory**. An **outpost** is a distinct Debian installation established at that site. Multiple outposts can operate at one site. Every outpost has its own hostname, enrolled identity, persistent state, connectivity, and Host Doctor; it is independently represented in the fleet. **Headquarters (HQ)** is the central control and inventory authority, not the host on which an outpost happens to run.

This is a **military-inspired operational metaphor**, not a literal security or virtual-machine boundary. A Docker-based outpost shares a Linux kernel with its execution environment, and may have restrictions that a bare-metal Debian host does not. An outpost should nevertheless be configured and monitored as an independent operating-system instance wherever the substrate permits.

The surrounding ecosystem uses Dark Souls names (`hosts-of-embers`, Firelink, Majula, `kindle`); Outpost uses a military deployment vocabulary while retaining that ecosystem's practical, short naming style.

## Canonical terms

| Term | Exact meaning | Owner |
|---|---|---|
| **Site** | Linux/Windows outer machine and container/VM substrate on which outposts run; a site can host several outposts | Underlying container runtime |
| **Outpost** | One deployed Debian OS instance with independent persistent state, node identity, and lifecycle | `axjab/outpost` |
| **Outpost image** | Reusable, versioned OCI Debian filesystem template, not containing a node's identity or secrets | `axjab/outpost` |
| **Deployment** | Creating/configuring an outpost instance at a site (image, volumes, names, network, lifecycle) | Container runtime / future bootstrap automation |
| **Headquarters (HQ)** | Central coordination, inventory, enrollment, and telemetry destination | Existing fleet services / `hosts-of-embers` |
| **Roster** | Informal name for HQ's list of known nodes; **not** another inventory file or database | HQ is source of truth |
| **Enrollment** | Registering one OS instance with HQ and establishing trust; never inherited from the image | `kindle.sh` / `hosts-of-embers` workflow |
| **Kindling** | Initial provisioning of any cold Debian OS, physical or virtual; distinct from deployment | `kindle.sh`, **not** the Outpost installer |
| **Host Doctor** | CLI `hostdr` and planned daemon evaluating the OS on which they execute | `axjab/host-doctor` |
| **Core** | Existing APT package delivering scripts, dependencies, configurations, and daemons | Existing APT ecosystem (`apt.alj.cx`) |
| **Identity** | Unique per-outpost SSH/GPG credentials, VPN enrollment, machine registration; stored outside image | Node-local runtime state and `gopass` trust path |
| **Provisioning** | Idempotent OS configuration, optionally with Ansible; can target outposts or actual servers | Shared host bootstrap workflow |

Use **outpost** for the deployable Debian node, **site** for its substrate, and **HQ** for the remote fleet authority. Do not use *host* ambiguously when the distinction matters: say **outer host/site** or **managed node/outpost**.

## Component and command names

**Outpost is an image, not a command.** Do not invent a lifecycle CLI for it.

- Image/repository: `axjab/outpost`; proposed OCI reference `ghcr.io/axjab/outpost` (not published).
- Runtime operations: `kiri build`, `kiri run`, `kiri ps`, `kiri exec`, `kiri stop` (Docker-compatible).
- `kindle.sh`: cold-host provisioning and enrollment, managed by `hosts-of-embers` and applicable to both physical and virtual Debian nodes.
- `hostdr`: node-local health CLI; its future daemon belongs to `host-doctor`.
- `gopass`: secrets, provisioned after deployment; never embedded in public image.
- `core`: existing public-dependency metapackage, installed through the APT ecosystem.
- `ansible`: optional declarative provisioning across real and virtual hosts.

Use military vocabulary for deployment architecture, not misleading replacements for ordinary technical operations.

## Ownership boundaries

```text
                                  Headquarters
                             hosts-of-embers / HQ
                      inventory, enrollment, telemetry
                                        ^
                          independently enrolled nodes
                                        |
            Site A                      |               Site B
      (physical Linux)                  |         (Linux / Windows + VM)
       +--- Outpost alpha ----------------------------- Outpost gamma
       |     |- persistent identity       |                |- independent identity
       |     |- kindle on first setup     |                |- kindle on first setup
       |     `- hostdr for alpha          |                `- hostdr for gamma
       +--- Outpost beta                 |
       |     |- distinct identity        |
       |     `- hostdr for beta           |
       `--- optional site-level Doctor   |
             (separate HQ record)        |

   Future real Debian server: kindle directly, hostdr locally;
   never requires an outpost deployment.
```

1. **Deployment** creates an outpost using Docker API/Kiri (Linux first); the site is a substrate, not the Doctor's target.
2. **Kindling** prepares/enrolls an already existing, cold Debian OS, whether an outpost or a real server.
3. **Inspection** is performed per OS by `hostdr`; a site's own Doctor and an outpost's Doctor are distinct.
4. **Provisioning** may be expressed as Ansible roles to reuse across virtual and physical Debian nodes.
5. **Secrets** are provisioned after trust is established, not copied from the site or baked into the image.

## Security / publishing policy

**Target:** public source, public distributable image. **Release gate:** audited content, not an assumption that a public registry is safe.

- Do not commit or embed SSH/GPG private keys, decrypted `gopass` data, `.env` secrets, token values, VPN state, HQ enrollment secrets, private inventories, or unique machine IDs.
- Never copy per-node state from an existing outpost into the image; each deployment enrolls separately.
- Review `core` package payload **and maintainer scripts**, APT source configuration, build context, image history and logs before publishing.
- Secrets obtained through `gopass` must have a separate first-trust mechanism. Installing `gopass` alone does not grant decrypt access.
- Keep mutable node state outside the replaceable image; document exactly which mounts are persistent. An updated image does **not** preserve arbitrary changes made to the container root filesystem.
- Audit whether public configuration exposes private topology even when it contains no passwords.
- Use explicitly versioned/digest-pinned images, prevent secret exposure in build cache and CI logs, and publish only after tests.

## Naming decision record

| Candidate | Assessment |
|---|---|
| **Outpost** | **Selected**: distributed military installation, enduring local identity, clear fit with HQ and multi-site fleet |
| Embassy | Diplomatic, but suggests principal mission; less aligned with preferred military terminology |
| Consulate | Accurate multiple-instances analogy, but rejected by user on thematic preference |
| Garrison | Refers chiefly to troops stationed somewhere rather than the independently managed installation |
| Bastion | Strong military word, but implies a security gateway/hardening purpose that is not the product's main role |
| Bonfire | Strong Souls resonance, but suggests a checkpoint rather than an independent OS node |

**Known naming overlap:** other products use `Outpost` for remote Linux/container development. This is an accepted namespace/discoverability tradeoff, not proof of legal clearance or CLI uniqueness. Continue with `axjab/outpost`; avoid conflicting global installs.

## Rule for future changes

Every new script or service must clearly own exactly one of: **deployment**, **cold-OS kindling**, **per-node health inspection**, **HQ fleet coordination**, **provisioning**, or **secrets/trust**. Choose the technically descriptive name first; use the Outpost theme only where it clarifies the system. Document new terms here before introducing them into scripts.
