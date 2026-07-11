# Nix Config

This repository is a single root flake for three targets:

1. NixOS system: `.#nixos`
2. Ubuntu desktop Home Manager profile: `.#ubuntu-desktop`
3. macOS nix-darwin systems: `.#mac` and `.#mac-work`

Use the root flake directly. There is no `hosts/` flake directory anymore.

## Structure

1. `flake.nix` - root entry point and lock file owner
2. `configuration.nix` - NixOS system configuration
3. `hardware-configuration.nix` - NixOS hardware configuration
4. `darwin/` - macOS system modules
5. `home.common.nix` - shared Home Manager config
6. `home.nix` - Linux user config
7. `home/ubuntu-desktop.nix` - Ubuntu desktop Home Manager profile
8. `home/darwin-*.nix` - macOS user profiles
9. `nixvim.nix`, `home/nixvim/` - modular Neovim config via nixvim
10. `vscode.nix`, `home/vscode/`, `tmux.nix` - modular editor and terminal tooling
11. `scripts/` - installed helper commands
12. `vendor/` - local Neovim plugin sources and helper Lua modules

## NixOS

Clone the repo and switch to the NixOS configuration:

```bash
git clone <REPO_URL> ~/new_config
cd ~/new_config
sudo nixos-rebuild switch --flake .#nixos
```

## macOS

Install Nix first, then clone the repo:

```bash
git clone <REPO_URL> ~/new_config
cd ~/new_config
```

Bootstrap nix-darwin for the personal machine:

```bash
sudo nix run nix-darwin#darwin-rebuild -- switch --flake .#mac
```

Apply later changes:

```bash
sudo darwin-rebuild switch --flake .#mac
```

For the work profile:

```bash
sudo darwin-rebuild switch --flake .#mac-work
```

Absolute paths are also valid:

```bash
sudo darwin-rebuild switch --flake /Users/q/new_config#mac
```

## Ubuntu Desktop

Install Nix, clone the repo, and apply the Home Manager profile:

```bash
git clone <REPO_URL> ~/new_config
cd ~/new_config
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager -- switch --flake .#ubuntu-desktop
```

## Update And Validate

Update inputs:

```bash
nix flake update
```

Validate all configured systems without building them:

```bash
nix flake check --all-systems --no-build
```

Apply the target you use:

```bash
# NixOS
sudo nixos-rebuild switch --flake .#nixos

# Ubuntu desktop
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager -- switch --flake .#ubuntu-desktop

# macOS personal
sudo darwin-rebuild switch --flake .#mac

# macOS work
sudo darwin-rebuild switch --flake .#mac-work
```

## Helper Scripts

The Home Manager config installs these helper commands:

1. `nix-apply` - applies the detected target without updating inputs
2. `nix-check` - runs the standard flake and repo checks
3. `nix-clean` - shows generations, prunes old user generations, and runs GC
4. `nix-diff-lock` - previews how `flake.lock` would change after an update
5. `nix-rollback` - lists generations or rolls back the current system/profile
6. `nix-update` - updates inputs, validates every target, and applies the detected target

Target detection is shared by `nix-apply` and `nix-update` through the internal
`nix-target` helper. The repository is resolved from `NIX_CONFIG_REPO`, the
current Git root, or `$HOME/new_config`, in that order.

`nix-update` auto-detects:

1. NixOS: `sudo nixos-rebuild switch --flake <repo>#nixos`
2. Ubuntu or other non-NixOS Linux: Home Manager with `<repo>#ubuntu-desktop`
3. macOS user `q`: `sudo darwin-rebuild switch --flake <repo>#mac`
4. macOS user `ppy`: `sudo darwin-rebuild switch --flake <repo>#mac-work`

Normal use:

```bash
nix-apply
nix-check
nix-diff-lock
nix-update
nix-clean
```

Dry runs:

```bash
nix-apply --dry-run
nix-update --dry-run
nix-clean --dry-run
```

Keep only generations newer than a given number of days:

```bash
nix-clean --keep-days 14
nix-clean --dry-run --keep-days 30
```

Rollback helpers:

```bash
nix-rollback --list
nix-rollback
nix-rollback --dry-run
nix-rollback 42
```

`nix-rollback` with a numeric generation is supported for system profiles. For Home Manager-only machines, use plain `nix-rollback` to roll back to the previous generation.

`nix-update` does not activate a changed lock file until
`nix flake check --all-systems --no-build` succeeds. A failed check leaves the
updated `flake.lock` in the working tree for inspection.

## Secrets

SOPS integration is intentionally disabled until the repository has a real
public age recipient. Never commit private age keys or decrypted secret files.

## Notes

If `nix-command` and `flakes` are not enabled globally, add them to Nix config:

```conf
experimental-features = nix-command flakes
```

For nix-darwin this is managed by `darwin/common.nix` after the first successful activation.
