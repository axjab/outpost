
Current build with core package failed due to mullvad:

> Yes. Remove mullvad-vpn from core and put it in desktop-pkg if your desktops still need it. That lets Outpost use the shared core package without pulling in the Mullvad app, which expects systemd. github.com

Bump core’s version, publish it, and rerun the same Outpost build. If Outpost itself needs a VPN later, handle that separately.


Remove mullvad from core then proceed with build
