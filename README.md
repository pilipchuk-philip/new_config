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
9. `nixvim.nix` - Neovim config via nixvim
10. `vscode.nix`, `tmux.nix` - editor and terminal tooling
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
sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#mac
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
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/release-25.11 -- switch --flake .#ubuntu-desktop
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
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/release-25.11 -- switch --flake .#ubuntu-desktop

# macOS personal
sudo darwin-rebuild switch --flake .#mac

# macOS work
sudo darwin-rebuild switch --flake .#mac-work
```

## Helper Scripts

The Home Manager config installs these helper commands:

1. `nix-update` - updates flake inputs and applies the detected target
2. `nix-clean` - shows generations, prunes old user generations, and runs GC

`nix-update` auto-detects:

1. NixOS: `sudo nixos-rebuild switch --flake <repo>#nixos`
2. Ubuntu or other non-NixOS Linux: Home Manager with `<repo>#ubuntu-desktop`
3. macOS user `q`: `sudo darwin-rebuild switch --flake <repo>#mac`
4. macOS user `ppy`: `sudo darwin-rebuild switch --flake <repo>#mac-work`

Normal use:

```bash
nix-update
nix-clean
```

Dry runs:

```bash
nix-update --dry-run
nix-clean --dry-run
```

Keep only generations newer than a given number of days:

```bash
nix-clean --keep-days 14
nix-clean --dry-run --keep-days 30
```

## SOPS And Age

The repo is wired for `sops-nix` through Home Manager.

Current defaults:

1. `sops` and `age` are installed
2. age key path: `${HOME}/.config/sops/age/keys.txt`
3. `.sops.yaml` applies to `secrets/*.yaml`

Create an age key:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

Copy the printed `age1...` recipient into `.sops.yaml`.

Create an encrypted secrets file:

```bash
sops secrets/secrets.yaml
```

Example plaintext while editing with SOPS:

```yaml
github_token: "ghp_..."
api_key: "..."
```

Use a secret from Home Manager:

```nix
sops.secrets.github_token = {
  sopsFile = ./secrets/secrets.yaml;
  path = "${config.home.homeDirectory}/.config/secrets/github_token";
};
```

After activation, the decrypted value is available at the configured path.

## Notes

If `nix-command` and `flakes` are not enabled globally, add them to Nix config:

```conf
experimental-features = nix-command flakes
```

For nix-darwin this is managed by `darwin/common.nix` after the first successful activation.
