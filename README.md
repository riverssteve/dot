# dotfiles

## Open the checkout

```sh
cd ~/code/dot
```

## Add a new home file (example)

```sh
chezmoi --source="$PWD" add --secrets=error ~/.config/zellij/layouts/custom.kdl
```

## Import an edit to a managed file (example)

```sh
chezmoi --source="$PWD" re-add ~/.config/zellij/config.kdl
```

## Edit a managed template (example)

```sh
chezmoi --source="$PWD" edit ~/.config/zellij/layouts/personal.kdl
```

## Preview and apply one file (example)

```sh
chezmoi --source="$PWD" diff ~/.config/zellij/layouts/personal.kdl
```

```sh
chezmoi --source="$PWD" apply ~/.config/zellij/layouts/personal.kdl
```

## Stage and review a repo change (example)

```sh
git switch -c fix/personal-layout
git status --short
git add -- dot_config/zellij/layouts/personal.kdl.tmpl
git diff --cached
```

## Commit and open a pull request (example)

```sh
git commit -m 'fix(zellij): update the personal layout'
git push -u origin fix/personal-layout && gh pr create --base main --head fix/personal-layout --fill
```

## Install chezmoi and clone a fresh checkout

```sh
curl -fsLS https://get.chezmoi.io | sh -s -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
git clone https://github.com/riverssteve/dot.git ~/code/dot
```

## Initialize a checkout and edit machine preferences

```sh
cd ~/code/dot
chezmoi --source="$PWD" init
chezmoi edit-config
```

## Preview and apply all dotfiles

```sh
chezmoi --source="$PWD" diff
```

```sh
chezmoi --source="$PWD" apply
```

## Run validation

```sh
./test.sh
```
