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

### Alt-сочетания для буфера обмена в Ubuntu

`scripts/ubuntu-keyd.nix` задаёт глобальные переназначения через `keyd`:
Alt+C → Ctrl+C, Alt+V → Ctrl+V, Alt+A → Ctrl+A, Alt+X → Ctrl+X.
Они работают в Wayland и X11; остальные сочетания Alt сохраняются.

Установить или обновить системную службу из корня репозитория:

```bash
nix --extra-experimental-features 'nix-command flakes' run path:.#ubuntu-keyd-setup
```

Команда запрашивает `sudo`, устанавливает конфиг `/etc/keyd/default.conf`,
службу `/etc/systemd/system/keyd.service` и автозагрузку модуля `uinput`.
Существующие файлы сохраняются с суффиксом `~`. Пакет берётся из закреплённого
`nixpkgs`; GC root `/nix/var/nix/gcroots/ubuntu-keyd` защищает его от очистки.
`path:.` позволяет запускать команду и до добавления нового Nix-файла в Git.
Служба запускается сразу и при последующих загрузках Ubuntu.

В терминале Alt+C действует как Ctrl+C (прерывает процесс), а не как
Ctrl+Shift+C. Правый Alt (AltGr) сохраняет стандартное поведение.

Отключить переназначение:

```bash
sudo systemctl disable --now keyd.service
```

### Шрифты и чёткость текста в Ubuntu

Профиль `ubuntu-desktop` устанавливает оригинальные SF Pro и SF Mono из
архивов Apple с фиксированными SHA-256. SF Pro Text используется для интерфейса
GNOME и GTK, SF Pro Display — для заголовков окон, SF Mono — для моноширинного
текста и Ghostty. Лицензии Apple сохраняются в `share/doc` пакетов.

Сглаживание задаётся в `home/ubuntu-desktop.nix`: `antialiasing = true`,
`hinting = "none"`, `subpixelRendering = "none"`, а также соответствующими
настройками GNOME. Это grayscale-сглаживание, приближенное к современному macOS;
рендеринг текста Linux и macOS не будет полностью одинаковым.

Применение из корня репозитория:

```bash
nix --extra-experimental-features 'nix-command flakes' run .#home-manager -- switch --flake .#ubuntu-desktop
```

После применения выйди из сеанса и войди снова, перезапусти Ghostty.
Проверить выбранные шрифты можно командами:

```bash
fc-match sans-serif
fc-match monospace
gsettings get org.gnome.desktop.interface font-name
```

Для экрана открой **Настройки → Дисплеи** и сохрани родное разрешение монитора.
При слишком мелком интерфейсе попробуй масштаб 125% (дробное масштабирование),
сравнив чёткость с 100%. Для увеличения только текста без масштабирования окон
можно использовать:

```bash
gsettings set org.gnome.desktop.interface text-scaling-factor 1.15
# Вернуть обычный размер:
gsettings reset org.gnome.desktop.interface text-scaling-factor
```

На мониторах 1440p масштаб 200% обычно слишком крупный. Чёткость Retina
требует высокой физической плотности пикселей: настройка масштаба сама по себе
её не увеличивает. Частота обновления влияет на плавность, а не на чёткость текста.

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

Secrets are managed manually with SOPS and age; they are restored separately
from `nix-apply`. The commands are installed through Home Manager on all targets.
Automatic activation through sops-nix is not configured.

Initialize once, choosing a passphrase at the age prompt:

```bash
nix-secrets init
```

This creates `.sops.yaml` with your public recipient and a passphrase-encrypted
private key at `${XDG_CONFIG_HOME:-~/.config}/sops/age/keys.txt.age`.
Back up that encrypted key separately: the password alone cannot recover secrets
if the key is lost. Commit `.sops.yaml` and encrypted files, never private keys
or decrypted files. On another machine, restore the encrypted key to the same
location and use the repository's existing `.sops.yaml`; do not initialize again.

Encrypt and decrypt individual files (including binary files):

```bash
nix-crypt "my file"                  # creates my file.enc.json
nix-decript "my file.enc.json"       # creates my file.dec
```

Both commands prompt for the key's passphrase. Originals are preserved, output
files have mode `0600`, and existing output files are never overwritten.
The spelling `nix-decript` is intentional.

Save selected files to `secrets/` and restore them explicitly:

```bash
nix-secrets save ssh-personal ~/.ssh/id_ed25519
nix-secrets save ssh-personal-public ~/.ssh/id_ed25519.pub
nix-secrets save hosts /etc/hosts

nix-secrets restore ssh-personal ~/.ssh/id_ed25519
nix-secrets restore ssh-personal-public ~/.ssh/id_ed25519.pub
nix-secrets restore hosts /etc/hosts
```

Names use letters, digits, dots, underscores and hyphens. `save` creates
`secrets/NAME.enc.json` and refuses to overwrite it. To save an updated version,
use a new name or explicitly remove the old encrypted file first.
`restore` asks before replacing existing files and keeps a private backup under
`${XDG_STATE_HOME:-~/.local/state}/nix-secrets/backups/`. For `/etc/hosts`, it
also shows a diff and uses `sudo` to install the complete file with mode `0644`;
include the required localhost entries in the saved file. Other restored files
have mode `0600`, and `~/.ssh` is set to `0700`. Use the literal `/etc/hosts`
destination for the privileged operation. Temporary decrypted material is
removed on exit; plaintext never becomes a Nix build input.

## Notes

If `nix-command` and `flakes` are not enabled globally, add them to Nix config:

```conf
experimental-features = nix-command flakes
```

For nix-darwin this is managed by `darwin/common.nix` after the first successful activation.
