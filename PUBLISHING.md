# Publishing on GitHub

Suggested repository name: `chatgpt-nixos`

Suggested description: Community NixOS packaging for the official ChatGPT
Linux app, with an FHS wrapper and GNOME launcher integration.

Suggested topics: `nixos`, `nix`, `chatgpt`, `linux`, `desktop`, `packaging`.

1. Extract the source archive. Review the files and license notice.
2. Run the build and launch checks in README.md on NixOS, especially the
   changed packaged desktop entry. Record any untested behavior honestly.
3. Create an empty GitHub repository. Do not initialize another README or
   license in GitHub because both are included here.
4. From the extracted project directory, run:

```bash
git init -b main
git add .
git diff --cached --check
git status --short
git diff --cached --stat
git commit -m "Add experimental ChatGPT NixOS packaging"
```

5. Copy the exact repository URL from GitHub, then set it as the remote and
   push `main`. For example, with your actual URL substituted:

```bash
git remote add origin REPOSITORY_URL
git push -u origin main
```

Before committing, check that only source and documentation are staged.
Never force-add downloaded app archives, result symlinks or account data.
The .gitignore excludes common build artifacts and downloads.

For an initial release, describe it as experimental. Use a packaging tag
such as `v0.1.0`; the upstream app version is tracked separately. Publish
source only. GitHub's source archives are sufficient; do not attach the
proprietary app or an archive of the built Nix output.

No repository has been created or pushed by preparing these files.
