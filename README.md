# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) for Debian Linux,
Bazzite, and macOS (Apple Silicon and Intel).

## Update dotfiles

Run these commands from `~/code/dot`. Replace `PATH` with the file path in your
home directory, such as `~/.config/zellij/layouts/work.kdl`.

| Where the change is | What to do |
| --- | --- |
| A new file in your home directory | Run `chezmoi --source="$PWD" add PATH`. |
| An edited file that chezmoi already manages | Run `chezmoi --source="$PWD" re-add PATH`. This replaces the repo copy. If the repo file ends in `.tmpl`, edit the template directly instead. |
| A file you edited in this repo | Skip `add` and `re-add`. Use `chezmoi --source="$PWD" source-path PATH` to find the source file for a managed path. |

Preview the change with `chezmoi --source="$PWD" diff PATH`. To install the
selected file, run `chezmoi --source="$PWD" apply PATH`.

To save the change in Git, create a branch and review `git status`. Use `git add`
to stage only the intended repo files. Review `git diff --cached` before you commit.

## Set up

Install chezmoi and fetch the dotfiles:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init riverssteve/dot
```

For this existing checkout, use `chezmoi init --source="$PWD"` instead.
Review machine preferences with `chezmoi edit-config`, preview with `chezmoi diff`,
then run `chezmoi apply`. Include `--source="$PWD"` on these commands if this
checkout is not your configured source directory.

Applying installs packages and configures the login shell on Linux. The initial
package installation needs network access and sudo access. Package scripts run
again when their contents or Homebrew package lists change.

| System | Packages | Default shell |
| --- | --- | --- |
| Debian | apt for system dependencies and Docker; mise for current CLI tools | Fish |
| Debian with a `pi-` or `raspberry` hostname | Same package setup, with Pi aliases | Bash |
| Bazzite | Homebrew for CLI tools; existing Flatpak and rpm-ostree helpers for optional apps/system packages | Fish |
| macOS | Homebrew CLI tools and casks, including Ghostty and a Nerd Font | Existing login shell; Fish configured |

On Debian, mise supplies current Neovim, fzf, eza, Zoxide, Starship, Atuin, Zellij,
uv, Lazygit, Lazydocker, and Node. This avoids the older CLI versions shipped by
Debian stable. Bazzite uses the existing system container tooling. On macOS,
`colima start` starts the Docker VM; Docker Compose is linked into the CLI plugin
directory without replacing Docker's configuration or credentials.

## Machine preferences

The generated chezmoi config contains:

```toml
[data]
isWork = false
shell = "fish"
signingKey = ""
```

macOS defaults to `isWork = true`, and Pi hostnames default to `shell = "bash"`.
Override these in `chezmoi edit-config`. Run `chezmoi apply` after editing.
Re-running `chezmoi init` regenerates these defaults, so retain any local choices.

Git defaults to Steve's personal identity. Repositories under `~/code/kraken/`
use the work identity on all systems. Import your GPG key separately, then set
`signingKey = "8353500A1FD56B92!"` to enable automatic commit signing. Signing
stays disabled until a key is configured, so a fresh machine can commit.
Use an unmanaged `~/.gitconfig-local` for further Git overrides.

Fish reads local `~/.config/fish/secrets.fish` and `extras.fish`. Bash reads local
`~/.config/bash/secrets.local` and `extras.local`. These files are not managed.
GPG keys, Atuin history/credentials, and other private runtime data are not included.

The optional `configure-macos` command restores the old screenshot, Finder, Dock,
and text-correction preferences. Restart affected apps when convenient.

## Migration and validation

See [the migration inventory](docs/migration.md) for each config group imported
from `~/.dotfiles`, what was retained here, and what was left out. The old directory
is preserved; this migration does not apply changes to the live home directory.

With chezmoi, Fish, Python 3, Git, and Bash installed:

```sh
./test.sh
```

This renders and applies all platform variants into temporary homes, checks
platform selection and Git identities, and exercises portable helpers. ShellCheck
runs when available. It does not execute package installers or change system
preferences. Native package provisioning still needs to be checked on each OS.

The Debian installer was also run successfully in a disposable ARM64 Bookworm
container, including Docker Compose and all mise-managed tools. Bazzite and macOS
package provisioning has not been run as part of this migration.
