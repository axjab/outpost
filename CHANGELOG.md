Unreleased
  - Install Fastfetch and display system information when user a opens an interactive Bash terminal.
  - Document the kindling-state storage decision; implementation remains deferred.

Version 0.1.0
  - Add Node.js 26 from the official `node:26-slim` image as a multi-stage build source.
  - Copy Node.js and its bundled npm into the Debian Trixie Outpost image without changing the final base image.

Version 0.0.0
  - it works
Unreleased
  - Show Fastfetch, the image version, and policy-based kindling status at interactive login.
  - Add composable kindling checks based on the legacy Kindle diagnostics.
  - Use the existing Fastfetch installation from `core`; do not install it separately.
