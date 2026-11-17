
Version 0.2.0 not there yet

Version 0.1.0
  - Add Node.js 26 from the official `node:26-slim` image as a multi-stage build source.
  - Copy Node.js and its bundled npm into the Debian Trixie Outpost image without changing the final base image.

Version 0.0.0
  - it works

Version 0.2.0 (unreleased)\n  - Keep shared Bash defaults in the image and user settings in the home directory.\n  - Initialize an empty home with an empty user `.bashrc`, `.bash_logout`, and `.config`.\n  - Bake the Outpost version into a root-owned, read-only file.\n\n