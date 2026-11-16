Unreleased
  - Show Fastfetch, the image version, and policy-based kindling status at interactive login.
  - Add composable kindling checks based on the legacy Kindle diagnostics.
  - Use Fastfetch from the existing `core` metapackage; do not install it separately.

Version 0.1.0
  - Add Node.js 26 from the official `node:26-slim` image as a multi-stage build source.
  - Copy Node.js and its bundled npm into the Debian Trixie Outpost image without changing the final base image.

Version 0.0.0
  - it works
