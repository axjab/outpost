# Outpost

Outpost gives you a personal Debian 13 environment running inside a Docker container.

It lets you bring your own Debian userspace to a machine without installing Debian on the host operating system. Even on a Windows machine, Docker provides the runtime needed to launch your own Outpost.

## What you get

- Debian 13 (Trixie), based on the slim image.
- A dedicated user named `a`, with Bash as the default shell.
- `sudo` access for package management.
- Your `core` package and its tools.
- `nb` for notes and `hx` (Helix) as the editor.
- A published image available through GitHub Container Registry.
- A Compose configuration to start and manage the container.
- A persistent home directory mounted at `./vol/home`.

## Start Outpost

With Docker and Docker Compose installed, run:

```bash
docker compose up -d
```

Open a shell inside your Debian environment:

```bash
docker compose exec outpost bash
```

Update the system from inside the container:

```bash
sudo apt update
sudo apt upgrade
```

## Build and publish

Build a versioned image:

```bash
OUTPOST_VERSION=0.0.0 ./do/build
```

Authenticate with GitHub Container Registry, then publish:

```bash
echo "$GHCR_TOKEN" | sudo docker login ghcr.io -u axjab --password-stdin
OUTPOST_VERSION=0.0.0 ./do/push
```

The image is published as:

```text
ghcr.io/axjab/outpost:latest
ghcr.io/axjab/outpost:0.0.0
```

## Where this is going

The goal is to make deploying an Outpost on a foreign machine as simple as running one command:

```bash
curl -fsSL https://... | bash
```

That command will eventually handle installation, configuration, and deployment automatically.

For now, Docker and Compose provide the working foundation. The automated installer is a future step.

## Important

Outpost is a container, not a full virtual machine. It uses the Linux kernel provided by its container runtime.

The Compose setup persists `/home/a` on the host. It does not automatically preserve every system-level change when a container is replaced.
