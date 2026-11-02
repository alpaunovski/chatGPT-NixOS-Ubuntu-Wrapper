# Contributing

Keep changes focused on packaging and desktop integration. Contributions to
the packaging code and documentation are submitted under this project's MIT
license. Do not submit upstream binaries, artwork, account data or credentials.

For changes to default.nix, evaluate and build on x86_64 NixOS, launch as a
normal user, and record your NixOS/Nixpkgs version and desktop session. Check
the installed desktop entry, startup, restart, and any feature the change
affects. Clearly distinguish tests you ran from tests still needed.

For the launcher script, run `bash -n scripts/install-launcher.sh`. Test it
with a temporary XDG_DATA_HOME and an explicit executable path before using
your actual application directory. Keep Chromium sandboxing enabled.

For upstream updates, follow README.md. A hash mismatch alone is not evidence
that an update is trustworthy. Check the official origin, package metadata,
dependency list and layout, then update version and checksum together.
