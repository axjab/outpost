Unreleased
  - Show Fastfetch, the image version, and policy-based kindling status at interactive login.
  - Add composable kindling checks based on the legacy Kindle diagnostics.
  - Use Fastfetch from the existing `core` metapackage; do not install it separately.

Version 0.1.0
  - Add Node.js 26 from the official `node:26-slim` image as a multi-stage build source.
  - Copy Node.js and its bundled npm into the Debian Trixie Outpost image without changing the final base image.

Version 0.0.0
  - it works

Version 0.2.0 (unreleased)\n  - Keep shared Bash defaults in the image and user settings in the home directory.\n  - Initialize an empty home with an empty user `.bashrc`, `.bash_logout`, and `.config`.\n  - Copy the fixed repository `VERSION` into `/usr/share/outpost/version`; use it for image tags without a configurable build argument.\n\n