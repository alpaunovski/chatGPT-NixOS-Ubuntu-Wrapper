# ChatGPT for NixOS

Community packaging for the **official ChatGPT Linux desktop app**, using
Nix's `buildFHSEnv` to supply the filesystem layout and runtime libraries
expected by the upstream Debian package.

**Experimental, x86_64 only.** This project is independent of OpenAI. NixOS
is not an officially supported distribution. The repository contains the
packaging source, documentation and launcher script; the app is downloaded
from OpenAI during the build.

## Status

| Item | Status |
| --- | --- |
| Upstream app version | `26.1027.51404` |
| Architecture | `x86_64-linux` / Debian `amd64` |
| Packaging approach | Unmodified upstream app directory in a Nix FHS environment |
| Original package | Built and used by the initial NixOS user |
| GNOME application launcher | Manual user-local desktop entry confirmed working |
| Packaged desktop-entry improvement | Included in this revision; needs a rebuild and GUI validation |
| Automated Nix build validation | Not performed in the preparation environment |
| Login callbacks, keyring, GPU and local Work/Codex tools | No comprehensive validation matrix yet |

A working launch does not establish that every desktop feature works.
Please report your NixOS/Nixpkgs version when reporting compatibility.

## Requirements

- NixOS on an x86_64 processor. Check with `uname -m`.
- Nix with an available `<nixpkgs>` channel, or a package set supplied by
  your existing NixOS/Home Manager configuration.
- A graphical desktop session. GNOME is the initial user's environment.
- Network access to OpenAI's download host and your Nix dependency sources.
- A ChatGPT account and access to the features you intend to use.
- Disk space for about 510 MiB of upstream download, approximately 1.7 GiB
  of extracted app files, plus Nix dependencies and build working space.

This repository has no flake and no `flake.lock`. Dependencies come from
whichever Nixpkgs revision you supply; only the app archive is checksum pinned.

## Quick start

Download and extract the source archive, or clone this repository. Open a
terminal in the project directory containing `default.nix`:

```bash
nix-build
./result/bin/chatgpt
```

Run the application as your normal desktop user, without `sudo`.
The build extracts the `.deb`; it does not run Debian maintainer scripts,
configure apt repositories, or modify your NixOS configuration.

If Nix cannot resolve `<nixpkgs>`, use an existing Nixpkgs source, for example:

```bash
nix-build -I nixpkgs=/absolute/path/to/nixpkgs
```

Use a real Nixpkgs checkout or store path, not a NixOS configuration directory.

## Install into your user profile

After building and checking that it launches:

```bash
nix profile add ./result
```

This uses the modern profile command. `nix profile install` is an older
alias; `nix-env` cannot manage a profile created by `nix profile`.
If Nix says the `nix-command` experimental feature is disabled, enable it
in your Nix settings or pass `--extra-experimental-features nix-command`
to the `nix` command.

The package includes a desktop entry and icon. Search for **ChatGPT** in
the application overview. This revision uses an absolute executable path
in the packaged desktop entry and registers only the `codex:` callback
scheme, leaving web and document defaults alone.

### If GNOME still does not show the launcher

The initial user needed a desktop entry in their user application directory.
The included helper reproduces that working fix:

```bash
bash scripts/install-launcher.sh "$HOME/.nix-profile/bin/chatgpt"
```

The helper checks that the executable exists, respects `XDG_DATA_HOME`,
and creates `applications/chatgpt.desktop` beneath it (normally
`~/.local/share/applications/chatgpt.desktop`). It replaces an existing
user-local `chatgpt.desktop` at that location. Run it without `sudo`.

If your profile executable is elsewhere, pass its absolute path instead:

```bash
command -v chatgpt
bash scripts/install-launcher.sh /absolute/path/to/bin/chatgpt
```

Use a persistent installed profile path rather than a temporary build
location. Log out and back in if the desktop does not refresh the menu.
The helper creates a menu entry; it does not pin it to the GNOME dash.
After launching, use GNOME's **Add to Favorites** action if desired.

## Declarative installation

Copy this project directory into your configuration tree, for example as
`/etc/nixos/chatgpt-nixos`. In your NixOS module:

```nix
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
    (import ./chatgpt-nixos { inherit pkgs; })
  ];
}
```

Apply with `sudo nixos-rebuild switch`. Merge with your existing settings;
do not duplicate an existing `allowUnfree` declaration. If you use a selective
unfree predicate or externally created package set, configure that package
set according to your existing policy.

For Home Manager, add the same package import to `home.packages`:

```nix
home.packages = [
  (import ./chatgpt-nixos { inherit pkgs; })
];
```

The relative path is resolved against the file containing the import.
A flake-based NixOS configuration can import this expression with its own
`pkgs`; this repository itself is not a flake. Ensure the project files
are tracked in your configuration repository when using Git-backed flakes.

## Wayland and graphics

Start with the app's default behavior. OpenAI documents native Wayland as
experimental; the app normally uses XWayland when available. To test native
Wayland, fully quit the running app first:

```bash
chatgpt --ozone-platform=wayland
```

If the profile executable is not on your shell's PATH, use
`./result/bin/chatgpt` instead. Window positioning, focus and shortcuts may
differ between sessions. This package does not configure your GPU drivers,
GNOME services, portals, keyring or XWayland installation.

Keep Chromium's sandbox enabled. If a sandbox or namespace error occurs,
report the exact output rather than adding `--no-sandbox`.
The FHS wrapper supplies compatibility paths; it is not an account-data
isolation boundary. The app runs with your user access.

## Source integrity and updates

The expected SHA-256 of the inspected official Debian archive is:

```text
46f1e22d028698fe9edaefd5847aece07c4509a30d3709e104220719d8c12822
```

The upstream download URL includes `/latest/`. When OpenAI replaces that
file, a clean build may fail with a hash mismatch. The checksum intentionally
prevents silently accepting different bytes. This project does not currently
have an immutable historical download URL.

You can place the matching official archive at `chatgpt_amd64.deb` beside
`default.nix`. It is ignored by Git. The build checks its checksum, version
and architecture, including when using that local override. Obtain it from
OpenAI; this project does not redistribute it.

To update the package:

1. Retrieve the new archive through the official Linux installation page.
2. Inspect it with `dpkg-deb -f` and `dpkg-deb -c`; check version,
   architecture, dependencies, executable paths and desktop integration.
3. Calculate its SHA-256 with `sha256sum` and update `version`, the fetch
   checksum, and the install-phase checksum in `default.nix` together.
4. Remove or replace any old local archive. Update this README's version,
   checksum and validation notes.
5. Build and test on NixOS, including the application menu, restart, login,
   callbacks and any local tools affected by the update.
6. Replace the installed profile entry or rebuild your declarative system.

For profile updates, inspect `nix profile list`, remove the exact old entry
with `nix profile remove ENTRY`, and add the newly built `./result`.
Replace `ENTRY` with the identifier reported by your installed Nix version.
A profile installed from a build output has no automatic upstream update
tracking. Debian/apt updates do not update this Nix installation.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| `nix-env` reports an incompatible profile | Use `nix profile add ./result` after building. |
| No GNOME launcher | Run the included launcher helper against your installed executable; log out and back in if needed. |
| Launcher appears but does not start | Inspect its `Exec` path and run that executable from a terminal. |
| Launcher icon is missing | Check the installed package's `share/pixmaps` and your session's `XDG_DATA_DIRS`; the helper uses the `chatgpt` icon name. |
| Download hash mismatch | Follow the update procedure; do not simply copy the reported new hash. |
| Local `.deb` rejected | It must match the pinned checksum, version and architecture. |
| Callback does not open the app | Inspect `xdg-mime query default x-scheme-handler/codex`; if necessary register the installed entry with `xdg-mime default chatgpt.desktop x-scheme-handler/codex`. |
| Missing library or Nix attribute | Include the exact error and Nixpkgs revision in a bug report. |
| GPU, keyring, sandbox or portal error | Include terminal output and session details; these features need host validation. |

Useful diagnostics:

```bash
nixos-version
nix --version
uname -m
printf '%s\n' "$XDG_SESSION_TYPE"
command -v chatgpt
nix profile list
chatgpt
```

Redact credentials, private paths and account information before posting logs.
OpenAI documents desktop Computer Use as unavailable in the Linux preview;
this wrapper cannot enable an upstream platform feature.

## Uninstall

For a profile installation, identify the entry with `nix profile list`,
then run `nix profile remove ENTRY` using its actual identifier.
For a declarative installation, remove the package import and rebuild.

If you used the launcher helper, remove its generated entry:

```bash
rm -f -- "${XDG_DATA_HOME:-$HOME/.local/share}/applications/chatgpt.desktop"
```

This does not remove the app's user data. The project intentionally does not
provide a command that deletes account sessions or conversation-related data.

## Project files

| File | Purpose |
| --- | --- |
| `default.nix` | Checksum-pinned upstream payload and FHS runtime wrapper |
| `scripts/install-launcher.sh` | User-local desktop entry fallback |
| `LICENSE` | MIT license for this project's code and documentation |
| `THIRD_PARTY_NOTICES.md` | Scope of licensing and upstream ownership |
| `CONTRIBUTING.md` | Contribution and verification guidance |
| `PUBLISHING.md` | Initial GitHub publication steps |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Environment and error report template |

## License

The packaging code, scripts and documentation are licensed under **MIT**;
see [LICENSE](LICENSE). The proprietary ChatGPT application and OpenAI
artwork are excluded from that grant. The resulting app package retains
`unfree` metadata. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## References

- [Official ChatGPT Linux documentation](https://learn.chatgpt.com/docs/linux/linux-app)
- [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/)
- [MIT license](https://opensource.org/license/mit)
