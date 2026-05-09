# Nix Config (Linux + macOS)

This repository contains host-specific `flake` configurations for:

1. NixOS via `hosts/nixos`
2. Ubuntu desktop via `hosts/ubuntu-desktop`
3. macOS via `hosts/mac`

Home Manager is already integrated for both targets, so no separate HM setup is required.

## Structure

1. `hosts/nixos/flake.nix` - NixOS entry point and Linux lock file owner
2. `hosts/ubuntu-desktop/flake.nix` - Ubuntu desktop Home Manager host
3. `hosts/mac/flake.nix` - macOS entry point and Darwin lock file owner
4. `configuration.nix` - NixOS system configuration
5. `darwin/` - macOS system modules
6. `home.common.nix` - shared user packages and shell config
7. `home.nix` - Linux-specific user config
8. `home/darwin-*.nix` - macOS-specific user configs
9. `nixvim.nix` - Neovim configuration via nixvim

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
sudo nixos-rebuild switch --flake ./hosts/nixos#nixos
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
nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake ./hosts/mac#mac
```

### 3) Apply further changes

```bash
darwin-rebuild switch --flake ./hosts/mac#mac
```

## Ubuntu Desktop (Home Manager)

### 1) Preparation

1. Install Nix.
2. Clone this repository:

```bash
git clone <REPO_URL> ~/new_config
cd ~/new_config
```

### 2) Apply the user environment

```bash
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/release-25.11 -- switch --flake ./hosts/ubuntu-desktop#ubuntu-desktop
```

## Update and Validation

1. Update the host lock file you actually use:

```bash
cd hosts/nixos && nix flake update
cd hosts/ubuntu-desktop && nix flake update
cd hosts/mac && nix flake update
```

2. Validate the flake (without building):

```bash
cd hosts/nixos && nix flake check --no-build
cd hosts/ubuntu-desktop && nix flake check --no-build
cd hosts/mac && nix flake check --no-build
```

3. Apply changes:

```bash
# Linux
sudo nixos-rebuild switch --flake ./hosts/nixos#nixos

# Ubuntu desktop
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/release-25.11 -- switch --flake ./hosts/ubuntu-desktop#ubuntu-desktop

# macOS
darwin-rebuild switch --flake ./hosts/mac#mac
```

## Helper Scripts

This repo includes reusable scripts in `scripts/`. The full `scripts/` directory is available in PATH after you apply the config:

1. `nix-update` - updates flake inputs and applies the system config
2. `nix-clean` - shows generations, prunes old user generations, runs GC

Current scripts in `scripts/`:

1. `nix-update`
2. `nix-clean`

These commands are available after you apply the config (`nixos-rebuild` or `darwin-rebuild`).

Both scripts auto-detect the current host type:

1. NixOS: uses `nixos-rebuild` with `./hosts/nixos#nixos`
2. Ubuntu/non-NixOS Linux: uses Home Manager with `./hosts/ubuntu-desktop#ubuntu-desktop`
3. macOS user `q`: uses `darwin-rebuild` with `./hosts/mac#mac`
4. macOS user `ppy`: uses `darwin-rebuild` with `./hosts/mac#mac-work`

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
sudo darwin-rebuild switch --flake "./hosts/mac#mac"
```

Work Mac (`ppy`):

```bash
sudo darwin-rebuild switch --flake "./hosts/mac#mac-work"
```

Use the `hosts/mac` flake directly.
