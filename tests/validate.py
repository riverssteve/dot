#!/usr/bin/env python3
"""Render and apply every platform to temporary homes; never run installers."""
import base64
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

SOURCE = Path(__file__).resolve().parents[1]
CHEZMOI = os.environ.get("CHEZMOI", "chezmoi")


def run(args, **kwargs):
    return subprocess.run([str(a) for a in args], check=True, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs).stdout


def validate_platform(root, name, system, arch, distro, hostname):
    root.mkdir()
    home = root / "home"
    home.mkdir()
    facts = {"os": system, "arch": arch, "hostname": hostname,
             "homeDir": str(home), "osRelease": {"id": distro}}
    common = [CHEZMOI, "--source", SOURCE, "--destination", home,
              "--config", root / "config.toml", "--cache", root / "cache",
              "--persistent-state", root / "state.boltdb",
              "--override-data", json.dumps({"chezmoi": facts})]
    config = run(common + ["execute-template", "--init", "--file", SOURCE / ".chezmoi.toml.tmpl"])
    (root / "config.toml").write_text(config)
    data = json.loads(run(common + ["data", "--format", "json"]))
    assert data["isWork"] == (system == "darwin"), (name, data["isWork"])
    assert data["shell"] == ("bash" if hostname.startswith("pi-") else "fish")
    targets = json.loads(run(common + ["dump", "--format", "json"]))

    # Detect accidental home-directory pollution and platform leakage.
    for unwanted in ["README.md", "LICENSE", "AGENTS.md", "CLAUDE.md", "test.sh"]:
        assert unwanted not in targets, (name, unwanted)
    assert not any(p.startswith(("tests/", "docs/", ".github/")) for p in targets)
    assert ("Caskfile" in targets) == (system == "darwin")
    assert ("Brewfile" in targets) == (distro == "bazzite")
    assert (".config/fish/functions/mpl.fish" in targets) == (system == "darwin")
    assert (".local/bin/layer-rpm-packages" in targets) == (distro == "bazzite")
    assert targets[".gnupg"]["perm"] == 0o700
    assert targets[".gnupg/gpg-agent.conf"]["perm"] == 0o600
    assert targets[".local/bin/gwt"]["perm"] == 0o755

    # Check the actual generated files, including scripts assembled from templates.
    check_file = root / "syntax"
    for path, entry in targets.items():
        content = entry.get("contents", "")
        if path.startswith(".local/bin/") and entry["type"] == "file":
            assert content.startswith("#!"), (name, path, "executable needs a first-line shebang")
        assert "/Users/steve.rivers" not in content.replace(str(SOURCE), ""), (name, path)
        assert "$HOME/.dotfiles" not in content, (name, path)
        if entry["type"] == "script" or path.endswith((".sh", ".bash")) or path == ".bashrc" or content.startswith("#!/usr/bin/env bash"):
            check_file.write_text(content)
            run(["bash", "-n", check_file])
            if shutil.which("shellcheck"):
                run(["shellcheck", "-s", "bash", "-S", "warning", check_file])
        elif path.endswith(".fish"):
            check_file.write_text(content)
            run(["fish", "--no-config", "--no-execute", check_file])
        elif content.startswith("#!/usr/bin/env python3"):
            compile(content, path, "exec")
        elif path.endswith(".lua") and shutil.which("luajit"):
            check_file.write_text(content)
            run(["luajit", "-e", 'assert(loadfile(os.getenv("DOTFILES_CHECK_FILE")))'],
                env=dict(os.environ, DOTFILES_CHECK_FILE=str(check_file)))
    json.loads(targets[".config/zed/keymap.json"]["contents"])
    agent = targets[".gnupg/gpg-agent.conf"]["contents"]
    assert ("pinentry-mac" in agent) == (system == "darwin")
    if system == "darwin":
        assert ("/opt/homebrew/" in agent) == (arch == "arm64")
    else:
        assert "/opt/homebrew/" not in agent

    secrets = home / ".config/fish/secrets.fish"
    secrets.parent.mkdir(parents=True)
    secrets.write_text("# unmanaged local settings\n")
    run(common + ["apply", "--exclude", "scripts"])
    run(common + ["verify", "--exclude", "scripts"])
    assert secrets.read_text() == "# unmanaged local settings\n"

    env = dict(os.environ, HOME=str(home), GIT_CONFIG_NOSYSTEM="1",
               GIT_CONFIG_GLOBAL=str(home / ".gitconfig"), GIT_CONFIG_COUNT="0")
    for relative, email in [("code/personal project", "git@rivers.dev"),
                            ("code/kraken/project", "steve.rivers@kraken.tech")]:
        repo = home / relative
        repo.mkdir(parents=True)
        run(["git", "init", "--quiet", repo], env=env)
        assert run(["git", "-C", repo, "config", "user.email"], env=env).strip() == email
    assert run(["git", "config", "--global", "commit.gpgsign"], env=env).strip() == "false"
    # Per-machine choices must also work on Linux workstations.
    overridden = list(common)
    overridden[-1] = json.dumps({"chezmoi": facts, "isWork": True,
                                 "shell": "fish", "signingKey": "8353500A1FD56B92!"})
    customized = json.loads(run(overridden + ["dump", "--format", "json"]))
    assert ".config/fish/functions/mpl.fish" in customized
    assert "gpgsign = true" in customized[".gitconfig"]["contents"]
    print(f"PASS {name}: {len(targets)} targets, temporary apply, syntax, identities")
    return home, env


def validate_helpers(root, home, env):
    jwt = home / ".local/bin/jwt"
    encode = lambda value: base64.urlsafe_b64encode(json.dumps(value).encode()).decode().rstrip("=")
    token = f'{encode({"alg": "HS256"})}.{encode({"sub": "portable"})}.signature'
    assert '"sub": "portable"' in run([sys.executable, jwt, token])
    assert '"alg": "HS256"' in run([sys.executable, jwt], input=token)
    assert subprocess.run([sys.executable, jwt, "invalid"], capture_output=True).returncode == 1

    # Exercise Bash 3.2-compatible worktree creation and pruning against a local remote.
    repo = home / "code/personal project"
    (repo / "README").write_text("fixture\n")
    run(["git", "-C", repo, "add", "README"], env=env)
    run(["git", "-C", repo, "commit", "--quiet", "-m", "fixture"], env=env)
    remote = root / "remote.git"
    run(["git", "init", "--bare", "--quiet", remote], env=env)
    run(["git", "-C", repo, "remote", "add", "origin", remote], env=env)
    run(["git", "-C", repo, "push", "--quiet", "-u", "origin", "main"], env=env)
    (repo / ".envrc").write_text("# local fixture\n")
    helper_env = dict(env, ZELLIJ="")
    gwt = home / ".local/bin/gwt"
    run(["/bin/bash", gwt, "feature/portable"], cwd=repo, env=helper_env)
    worktree = repo / ".worktrees/feature-portable"
    assert (worktree / ".envrc").is_symlink()
    run(["/bin/bash", gwt, "--prune"], cwd=repo, env=helper_env)
    assert not worktree.exists()

    # Check clipboard routing without touching the real system clipboard.
    bins = root / "mock-bin"
    bins.mkdir()
    for command in ["base64", "tr"]:
        (bins / command).symlink_to(shutil.which(command))
    clipboard = home / ".local/bin/clipboard-copy"
    clip_env = dict(env, PATH=str(bins), WAYLAND_DISPLAY="", DISPLAY="")
    assert run(["/bin/bash", clipboard], input="portable", env=clip_env) == "\x1b]52;c;cG9ydGFibGU=\x07"
    for command, display in [("wl-copy", "wayland-0"), ("pbcopy", "")]:
        (bins / command).write_text("#!/bin/sh\n/bin/cat\n")
        (bins / command).chmod(0o755)
        assert run(["/bin/bash", clipboard], input="clipboard fixture", env=dict(clip_env, WAYLAND_DISPLAY=display)) == "clipboard fixture"

    # Decrypted Fish scripts retain line boundaries, and a decrypt failure
    # must prevent execution even if the command produced partial output.
    cipher = root / "environment.gpg"
    cipher.write_text("fixture")
    (bins / "fish").symlink_to(shutil.which("fish"))
    gpg = bins / "gpg"
    gpg.write_text("#!/bin/sh\nprintf 'set -gx PORTABLE_ENV ready\\n# last line comment\\n'\n")
    gpg.chmod(0o755)
    gpgenv = home / ".config/fish/functions/gpgenv.fish"
    command = f'''source "{gpgenv}"; gpgenv "{cipher}" /bin/sh -c 'printf "%s:%s" "$PORTABLE_ENV" "$1"' sh 'arg spaces' '''
    assert run([shutil.which("fish"), "--no-config", "-c", command], env=clip_env) == "ready:arg spaces"
    gpg.write_text("#!/bin/sh\nprintf 'echo should-not-execute\\n'\nexit 1\n")
    failed = subprocess.run([shutil.which("fish"), "--no-config", "-c", command], env=clip_env, text=True, capture_output=True)
    assert failed.returncode != 0 and failed.stdout == ""
    print("PASS helpers: JWT, worktree create/prune, clipboard, decrypted environment")


def main():
    fixtures = [
        ("debian", "linux", "amd64", "debian", "debian-test"),
        ("debian-pi", "linux", "arm64", "debian", "pi-test"),
        ("bazzite", "linux", "amd64", "bazzite", "bazzite-test"),
        ("macos-arm64", "darwin", "arm64", "", "mac-test"),
        ("macos-intel", "darwin", "amd64", "", "mac-test"),
    ]
    with tempfile.TemporaryDirectory(prefix="dotfiles-check-") as temp:
        root = Path(temp)
        for fixture in fixtures:
            home, env = validate_platform(root / fixture[0], *fixture)
            if fixture[0] == "debian":
                validate_helpers(root / fixture[0], home, env)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print(error.stderr, file=sys.stderr)
        raise
