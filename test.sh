#!/usr/bin/env bash
set -e

podman run --rm --hostname pi-test \
  -v "$(cd "$(dirname "$0")" && pwd):/dotfiles:ro,z" \
  debian:bookworm \
  bash -c '
    apt-get update -qq && apt-get install -y -qq curl ca-certificates sudo passwd > /dev/null 2>&1
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin > /dev/null 2>&1
    cp -r /dotfiles /tmp/dot && rm -rf /tmp/dot/.git
    chezmoi init --source=/tmp/dot
    chezmoi apply --source=/tmp/dot
  '
