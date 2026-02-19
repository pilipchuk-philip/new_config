# Nix Config (Linux + macOS)

This repository contains a single `flake` configuration for:

1. NixOS (`nixosConfigurations.nixos`)
2. macOS via nix-darwin (`darwinConfigurations.mac`)

Home Manager is already integrated for both targets, so no separate HM setup is required.

## Structure

1. `flake.nix` - entry point and system definitions
2. `configuration.nix` - NixOS system configuration
3. `darwin.nix` - macOS system configuration (nix-darwin)
4. `home.common.nix` - shared user packages and shell config
5. `home.nix` - Linux-specific user config
6. `home.darwin.nix` - macOS-specific user config
7. `nixvim.nix` - Neovim configuration via nixvim

## Linux Installation (NixOS)

### 1) Preparation

1. Install NixOS (graphical or minimal installer).
2. Log into the installed system.
3. Install `git` if needed:

```bash
nix-shell -p git
```

4. Clone this repository and enter it:

```bash
git clone <REPO_URL> ~/new_config
cd ~/new_config
```

### 2) Apply the system configuration

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## macOS Installation (nix-darwin)

### 1) Preparation

1. Install Nix (Determinate Nix Installer or the official installer).
2. Clone this repository:

```bash
git clone <REPO_URL> ~/new_config
cd ~/new_config
```

### 2) Bootstrap nix-darwin and apply for the first time

```bash
nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#mac
```

### 3) Apply further changes

```bash
darwin-rebuild switch --flake .#mac
```

## Update and Validation

1. Update the lock file:

```bash
nix flake update
```

2. Validate the flake (without building):

```bash
nix flake check --no-build
```

3. Apply changes:

```bash
# Linux
sudo nixos-rebuild switch --flake .#nixos

# macOS
darwin-rebuild switch --flake .#mac
```

## Helper Scripts

This repo includes reusable scripts in `scripts/` and installs them as shell commands:

1. `nix-update` - updates flake inputs and applies the system config
2. `nix-clean` - shows generations, prunes old user generations, runs GC

These commands are available after you apply the config (`nixos-rebuild` or `darwin-rebuild`).
Before first apply, use root wrappers: `./nix_update` and `./nix_clean`.

Both scripts auto-detect OS:

1. Linux: uses `nixos-rebuild` with `.#nixos`
2. macOS: uses `darwin-rebuild` with `.#mac`

### Normal Run

```bash
nix-update
nix-clean
```

### Dry Run

Use `--dry-run` to print commands without executing:

```bash
nix-update --dry-run
nix-clean --dry-run
```

`nix-clean` also supports `--keep-days N` to keep only generations newer than `N` days:

```bash
nix-clean --keep-days 14
nix-clean --dry-run --keep-days 30
```

Compatibility wrappers still exist in repo root:

1. `./nix_update` -> `nix-update`
2. `./nix_clean` -> `nix-clean`
