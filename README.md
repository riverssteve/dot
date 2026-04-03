# Chezmoi Multi-Machine Configuration

This repository contains my dotfiles managed by [chezmoi](https://www.chezmoi.io/), configured to support multiple machines with different requirements.

## Supported Machines

1. **MacBook Pro (Work)** - Fish shell, work-specific functions/aliases, Homebrew (with casks), Neovim with LazyVim
2. **Bazzite Linux** - Fish shell, Homebrew (CLI only), Flatpak, rpm-ostree, Neovim with LazyVim
3. **Raspberry PIs** - Bash shell, apt packages, Neovim with LazyVim

## How It Works

### Machine Detection

The configuration automatically detects your machine type using:
- `{{ .chezmoi.os }}` - Detects "darwin" (macOS) or "linux"
- `{{ .chezmoi.hostname }}` - Machine hostname (PIs should start with "pi-" or "raspberry")
- `{{ .chezmoi.osRelease.id }}` - Linux distribution

### Configuration Files

- `.chezmoi.toml.tmpl` - Main config that sets machine-specific variables
- `.chezmoiignore` - Excludes files not needed on specific machines
- `.chezmoidata.toml` - Default values for template variables

### File Naming Convention

- `filename.tmpl` - Template files processed by chezmoi
- `dot_filename` - Creates `.filename` in your home directory
- `dot_config/fish/` - Creates `~/.config/fish/`

## Initial Setup

### On This Machine (Bazzite)

```bash
# Initialize chezmoi with this repository
chezmoi init --apply /var/home/blackfyre/code/chezmoi

# Or if you have it in a git repository
chezmoi init --apply https://github.com/yourusername/dotfiles.git

# Install packages
install-brew-packages          # Install Homebrew CLI tools
install-flatpak-packages       # Install Flatpak GUI apps
layer-rpm-packages             # Layer system packages (optional, requires reboot)
```

### On MacBook Pro

```bash
# Install chezmoi
brew install chezmoi

# Initialize with your repository
chezmoi init --apply https://github.com/yourusername/dotfiles.git

# Install packages
brew bundle --file=~/Caskfile

# First time opening Neovim, it will install LazyVim and all plugins
nvim
```

### On Raspberry PI

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/yourusername/dotfiles.git

# Install Neovim (if not already installed)
sudo apt update && sudo apt install neovim

# First time opening Neovim, it will install LazyVim and all plugins
nvim
```

## Usage

### Adding New Files

```bash
# Add a file to chezmoi
chezmoi add ~/.config/fish/config.fish

# Add and make it a template (for conditional logic)
chezmoi add --template ~/.config/fish/config.fish
```

### Making Changes

```bash
# Edit a managed file
chezmoi edit ~/.config/fish/config.fish

# See what would change
chezmoi diff

# Apply changes
chezmoi apply -v
```

### Syncing Changes

```bash
# Pull latest changes from repository
chezmoi update

# Or manually
cd $(chezmoi source-path)
git pull
chezmoi apply
```

### Adding Machine-Specific Content

Use template conditionals in any `.tmpl` file:

```fish
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific content
{{- end }}

{{- if eq .chezmoi.os "linux" }}
# Linux-specific content
{{- end }}

{{- if .isWork }}
# Work machine only
{{- end }}
```

## Customization

### Modify Work Detection

Edit `.chezmoi.toml.tmpl` to change how work machines are detected (currently assumes all macOS = work).

### Add New Machine Types

Add conditions in templates using hostname or other chezmoi variables:

```
{{- if eq .chezmoi.hostname "my-gaming-pc" }}
# Gaming PC specific config
{{- end }}
```

### Package Managers

**macOS:**
- `Caskfile` - Homebrew formulae AND casks (GUI apps)
- Install: `brew bundle --file=~/Caskfile`

**Bazzite/Fedora Atomic:**
- `Brewfile` - Homebrew formulae only (CLI tools, no casks)
- `~/.local/share/chezmoi/flatpak-packages.txt` - Flatpak applications (GUI apps)
- `~/.local/share/chezmoi/rpm-ostree-packages.txt` - System packages to layer
- Helper scripts in `~/.local/bin/`:
  - `install-brew-packages` - Install Homebrew CLI tools
  - `install-flatpak-packages` - Install Flatpak apps
  - `layer-rpm-packages` - Layer rpm-ostree packages (requires reboot)

**Raspberry PI:**
- Manual `apt install` or create a package list as needed

## Files Structure

```
chezmoi/
├── .chezmoi.toml.tmpl                  # Main config template
├── .chezmoiignore                      # Ignore patterns
├── .chezmoidata.toml                   # Default data
├── Caskfile.tmpl                       # Homebrew packages (macOS - includes casks)
├── Brewfile.tmpl                       # Homebrew packages (Bazzite - CLI only)
├── dot_bashrc.tmpl                     # Bash config (Raspberry PI)
├── dot_bashrc.d/
│   └── raspberry_aliases.sh.tmpl      # PI-specific aliases
├── dot_config/
│   ├── fish/
│   │   ├── config.fish.tmpl           # Main fish config
│   │   └── conf.d/
│   │       ├── work_functions.fish.tmpl      # Work-specific (macOS)
│   │       └── linux_specific.fish.tmpl      # Linux-specific
│   └── nvim/                           # Neovim/LazyVim configuration
└── dot_local/
    ├── bin/                            # Helper scripts (Bazzite)
    │   ├── install-brew-packages
    │   ├── install-flatpak-packages
    │   └── layer-rpm-packages
    └── share/chezmoi/                  # Package lists (Bazzite)
        ├── flatpak-packages.txt
        └── rpm-ostree-packages.txt
```

## Neovim / LazyVim

This configuration includes a full LazyVim setup with:
- LSP support (Language Server Protocol)
- Auto-completion
- File explorer (neo-tree)
- Fuzzy finder (telescope)
- Git integration
- And much more!

### First Launch

On first launch, Neovim will:
1. Clone lazy.nvim (plugin manager)
2. Install LazyVim
3. Install all configured plugins
4. Install LSP servers and tools via Mason

This may take a few minutes. Just wait for it to complete.

### Customization

- Add custom plugins in `~/.config/nvim/lua/plugins/`
- Override LazyVim settings in `lua/config/options.lua`
- Add custom keymaps in `lua/config/keymaps.lua`
- See `lua/plugins/example.lua` for examples

### Useful LazyVim Commands

```
:Lazy - Plugin manager
:Mason - LSP/tool installer
:LazyExtras - Browse and enable LazyVim extras
:checkhealth - Check Neovim health
```

### Key Bindings

LazyVim uses `<space>` as the leader key:
- `<space>e` - Toggle file explorer
- `<space>ff` - Find files
- `<space>fg` - Live grep
- `<space>ca` - Code actions
- `K` - Hover documentation

See `:help LazyVim` for more information.

## Useful Chezmoi Commands

```bash
# Check what chezmoi would do
chezmoi apply --dry-run --verbose

# See differences
chezmoi diff

# Edit source files
chezmoi cd  # Opens source directory
git status
git add .
git commit -m "Update config"
git push

# Re-apply everything
chezmoi apply -v

# Unmanage a file
chezmoi forget ~/.config/some-file
```
