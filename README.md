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

This repo includes reusable scripts in `scripts/`. The full `scripts/` directory is available in PATH after you apply the config:

1. `nix-update` - updates flake inputs and applies the system config
2. `nix-clean` - shows generations, prunes old user generations, runs GC

Current scripts in `scripts/`:

1. `nix-update`
2. `nix-clean`

These commands are available after you apply the config (`nixos-rebuild` or `darwin-rebuild`).

Both scripts auto-detect OS:

1. Linux: uses `nixos-rebuild` with `.#nixos`
2. macOS user `q`: uses `darwin-rebuild` with `.#mac`
3. macOS user `ppy`: uses `darwin-rebuild` with `.#mac-work`

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

Compatibility wrappers were removed from the repo root.

## SOPS + age Secrets

This repo is wired for `sops-nix` via Home Manager on both NixOS and macOS.

Current defaults:

1. `sops` package is installed
2. key file path is `${HOME}/.config/sops/age/keys.txt`
3. `.sops.yaml` defines encryption rules for `secrets/*.yaml`

If you prefer storing the key in `~/.ssh`, change:

```nix
sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
```

to:

```nix
sops.age.keyFile = "${config.home.homeDirectory}/.ssh/age_sops_key.txt";
```

Then generate key there:

```bash
mkdir -p ~/.ssh
age-keygen -o ~/.ssh/age_sops_key.txt
chmod 600 ~/.ssh/age_sops_key.txt
age-keygen -y ~/.ssh/age_sops_key.txt
```

### 1) Create an age key for SOPS

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

Copy the `age1...` public recipient from the last command into `.sops.yaml` (replace `age1replace_with_your_public_recipient`).

### 2) Create encrypted secrets file

```bash
sops secrets/secrets.yaml
```

Example content inside editor:

```yaml
github_token: "ghp_..."
api_key: "..."
```

SOPS will save it encrypted (safe to commit).

### 3) Use a secret from Home Manager

Add this to `home.common.nix` (or OS-specific home file):

```nix
sops.secrets.github_token = {
  sopsFile = ./secrets/secrets.yaml;
  path = "${config.home.homeDirectory}/.config/secrets/github_token";
};
```
# darwin 
/etc/nix/nix.conf
```
experimental-features = nix-command flakes
```

After apply, the decrypted value will be available at that path.

## macOS Builds

Personal Mac (`q`):

```bash
sudo darwin-rebuild switch --flake "path:$PWD#mac"
```

Work Mac (`ppy`):

```bash
sudo darwin-rebuild switch --flake "path:$PWD#mac-work"
```

If all new files are already added to git, you can also use:

```bash
sudo darwin-rebuild switch --flake .#mac
sudo darwin-rebuild switch --flake .#mac-work
```
