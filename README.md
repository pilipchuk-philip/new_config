# Nix Config (Linux + macOS)

Репозиторий с единой `flake`-конфигурацией для:

1. NixOS (`nixosConfigurations.nixos`)
2. macOS через nix-darwin (`darwinConfigurations.mac`)

Home Manager уже встроен в оба варианта, отдельная установка HM не нужна.

## Структура

1. `flake.nix` - входная точка и сборка конфигураций
2. `configuration.nix` - системный конфиг NixOS
3. `darwin.nix` - системный конфиг macOS (nix-darwin)
4. `home.common.nix` - общие user-пакеты и shell-настройки
5. `home.nix` - Linux-специфичные user-настройки
6. `home.darwin.nix` - macOS-специфичные user-настройки
7. `nixvim.nix` - конфиг Neovim через nixvim

## Установка на Linux (NixOS)

### 1) Подготовка

1. Установить NixOS обычным способом (графический/минимальный инсталлер).
2. Войти в установленную систему.
3. Установить `git`, если его нет:

```bash
nix-shell -p git

```

4. Клонировать репозиторий и перейти в него:

```bash
git clone <URL_РЕПО> ~/new_config
cd ~/new_config
```

### 2) Применение системы

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## Установка на macOS (nix-darwin)

### 1) Подготовка

1. Установить Nix (рекомендуется Determinate Nix Installer или официальный установщик).
2. Клонировать репозиторий:

```bash
git clone <URL_РЕПО> ~/new_config
cd ~/new_config
```

### 2) Bootstrap nix-darwin и первое применение

```bash
nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#mac
```

### 3) Дальнейшее применение изменений

```bash
darwin-rebuild switch --flake .#mac
```

## Обновление и проверка

1. Обновить lock-файл:

```bash
nix flake update
```

2. Проверить флейк (без сборки):

```bash
nix flake check --no-build
```

3. Применить изменения:

```bash
# Linux
sudo nixos-rebuild switch --flake .#nixos

# macOS
darwin-rebuild switch --flake .#mac
```
