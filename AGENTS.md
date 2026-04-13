# Codex Agent Instructions for this Nix Config Repo

You are an automated coding agent working inside a Nix repository with host-specific flakes that targets:

- NixOS via `hosts/nixos`
- macOS via nix-darwin via `hosts/mac`
- Home Manager integrated for both
- Neovim configured via `nixvim.nix`

Your job is to propose and implement changes **safely, reproducibly, and with minimal surprise**.

---

## Core Rules

### 1) Keep changes small and reviewable

- Prefer small, atomic commits that do one thing.
- Do not mix formatting refactors with functional changes.
- If a change touches multiple files, explain why each file is necessary.

### 2) Respect the repo structure

- `hosts/nixos/flake.nix` and `hosts/mac/flake.nix` are the entry points: keep them readable and stable.
- `home.common.nix` = shared user config (packages, shell, common defaults).
- `home.nix` and `home.darwin.nix` = OS-specific user config only.
- `configuration.nix` = NixOS system config only.
- `darwin.nix` = macOS system config only.
- `nixvim.nix` = Neovim config only.

If unsure where something belongs, default to:

- user-level → Home Manager (`home.*.nix`)
- system-level → NixOS/darwin module (`configuration.nix` / `darwin.nix`)

### 3) Do not weaken security

- Never print or commit secrets.
- Never request secrets in plaintext.
- For secrets, use `sops-nix` and `.sops.yaml` rules.
- Do not add “temporary” insecure hacks (e.g., disabling SIP-related protections, weakening file permissions) unless explicitly requested.

### 4) Be reproducible

- Prefer Nix-native solutions over ad-hoc installs (brew/npm/curl), unless there is no viable nixpkgs option.
- If you add a new dependency:
  - pin it via nixpkgs inputs or standard Nix fetchers
  - avoid unpinned network downloads at build time

---

## Workflow Expectations

### Always start by understanding intent

Before changing code/config, quickly answer:

- Is this a Linux-only, macOS-only, or shared change?
- Should it live in system config or Home Manager?
- Will it affect activation steps (e.g., `/etc`, launchd, fonts, VS Code profiles)?

### Validate before applying

Prefer:

- `nix flake check --no-build`
- `nix eval` for attribute validation
- `nix build` if you only need build artifacts
- avoid full system activation unless requested

### Keep the tree clean when possible

- If the repo is dirty, do not delete or overwrite uncommitted work.
- If you must change many files, suggest committing/stashing first.

---

## macOS / nix-darwin Specific Rules

- Use:
  ```bash
  sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake ./hosts/mac#mac
  ```

## Codex Language: russian

Общайся со мной только на русском языке
