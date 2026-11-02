#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  printf 'Run this script as your desktop user, without sudo.\n' >&2
  exit 1
fi

executable=${1:-}
if [[ -z "$executable" ]]; then
  executable=$(command -v chatgpt || true)
fi
if [[ "$executable" != /* || ! -x "$executable" ]]; then
  printf 'Usage: %s /absolute/path/to/bin/chatgpt\n' "$0" >&2
  printf 'Install the package in your profile first.\n' >&2
  exit 1
fi
# Keep desktop-entry quoting predictable; refuse unusual paths instead of
# emitting an invalid Exec field. Do not resolve profile symlinks into store paths.
if [[ "$executable" == *[\"\`\$\\%]* || "$executable" == *$'\n'* || "$executable" == *$'\r'* ]]; then
  printf 'Unsupported special character in executable path.\n' >&2
  exit 1
fi

data_home=${XDG_DATA_HOME:-$HOME/.local/share}
mkdir -p "$data_home/applications"
desktop_file="$data_home/applications/chatgpt.desktop"
cat > "$desktop_file" <<EOF
[Desktop Entry]
Name=ChatGPT
Comment=ChatGPT by OpenAI
Exec="$executable" %U
Icon=chatgpt
Type=Application
Terminal=false
Categories=Utility;Development;
StartupNotify=true
MimeType=x-scheme-handler/codex;
EOF
chmod 644 "$desktop_file"
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$data_home/applications"
fi
printf 'Installed launcher: %s\n' "$desktop_file"
printf 'Search for ChatGPT in your application overview.\n'
