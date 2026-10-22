# Migration from ~/.dotfiles

Reviewed the old directory's working tree, including its uncommitted edits.
Imports are copies into chezmoi's source format. The old directory and the active
home configuration remain untouched.

| Old group | Decision and destination |
| --- | --- |
| `atuin/config.toml` | Imported to `~/.config/atuin/config.toml`; history and credentials excluded. |
| `starship/starship.toml` | Imported the current edited file to `~/.config/starship.toml`. |
| `editorconfig/editorconfig.symlink` | Imported the current edited file to `~/.editorconfig`. |
| `git/*.template`, `git/ignore` | Imported Git settings, both identities, and global ignores. Personal is the default; the work path overrides it. GPG uses PATH. Signing is enabled per machine after key import. |
| `ghostty/config` | Imported to `~/.config/ghostty/config`; the macOS Option key setting is conditional. |
| `gpg/*.conf` | Merged the identical agent settings into one template. Selects Homebrew pinentry on each Mac architecture; Linux uses its installed pinentry. The source `gpg.conf` is empty, so it was omitted. No keys imported. |
| `zed/*.json` | Imported settings and keymap; Command shortcuts become Control/Alt shortcuts on Linux. |
| `fish/config.fish` | Retained the existing chezmoi version. Initialized Homebrew and mise paths before tools, added direnv and GPG terminal support, and removed dependence on the old directory. |
| `fish/functions` | Retained existing wrappers, including the fixed `n` and Debian-aware `ff`. Imported `view` and GPG helpers. `gpgedit` uses private temporary storage and retains the original if editing/encryption fails. `gpgenv` preserves command argument boundaries. |
| `fish/functions/mpl.fish` | Imported as a work-only helper selected by `isWork`; removed duplicate `uv run` and preserved argument boundaries. |
| `fish/functions/fisher.fish` | Left out: vendored plugin manager with no plugin manifest in this configuration. |
| `bash/defaults`, `bash/install.sh` | Migrated current Readline, history, aliases, functions and tool initialization to `~/.inputrc`, `~/.bashrc`, and `~/.config/bash`. Removed Homebrew assumptions and old-directory sourcing. Retained Pi-specific additions only on Pi hostnames. |
| `neovim/nvim` | Most files were identical. Kept this repo's lockfile and local plugin, made the local plugin conditional on its checkout existing, and merged old worktree exclusions. Replaced hard-coded Python/Node provider paths with discovery. |
| `zellij` | Kept this repo's config/theme/layouts, fixed `horizontal` spelling, restored the explicit quit binding, and imported a portable personal layout pointing at the chezmoi source directory. |
| `zellij/layouts/work.kdl.template` | Left out: malformed quoting and unresolved work-directory placeholders. Existing `worktab` and `worktree` layouts remain available. |
| `bin/gwt` | Imported the currently edited helper. Fixed Bash 3.2 compatibility, paths with spaces, and premature exit during pruning. Default branch detection uses local Git metadata. Removed automatic trust of linked `.envrc` files; use `direnv allow` explicitly. |
| Other `bin/*` | Imported Git, PR, JWT and Zellij helpers to `~/.local/bin`. Corrected fixup commit selection and missing-upstream filtering. PR/commit copying supports macOS, Wayland, X11 and OSC 52 over SSH. `close` delegates to the named tab helper. |
| `homebrew/m1.brewfile` | Merged CLI dependencies, Docker/Colima, Ghostty and a Nerd Font into the existing package lists. Existing GUI selections retained; unrelated optional GUI apps were not added. The old pyenv packages are superseded by mise. |
| `macos/install.sh` | Preserved preference writes as the manual `configure-macos` helper. Omitted forced app termination. Docker Compose uses a managed plugin symlink, preserving existing Docker config. |
| `ubuntu/packages.sh` | Replaced by the Debian package path; no Ubuntu-only Snap dependency. |
| Root/component installers, `bootstrap.sh`, `utils.sh` | Left out: chezmoi now owns file placement and package provisioning. |
| `.github`, pre-commit config, `.claude`, `.git` | Old installer-specific automation, local tool permissions and repository metadata left out. Updated this repo's validation for all supported platforms. |

Platform rendering and temporary application are checked automatically. These
checks do not provision a native Bazzite or macOS machine, install Debian packages,
or validate external package download services.

Separately, the rendered Debian installer completed successfully in a disposable
ARM64 Debian Bookworm container, including all apt packages, Docker Compose, and
the 11 tools managed by mise. Bazzite and macOS package provisioning remains to be
verified on those machines.
