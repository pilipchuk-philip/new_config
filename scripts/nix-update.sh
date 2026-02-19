#!/bin/sh
set -eu

dry_run=0
if [ "${1:-}" = "--dry-run" ]; then
  dry_run=1
  shift
fi
if [ "$#" -ne 0 ]; then
  echo "Usage: nix-update [--dry-run]"
  exit 1
fi

run() {
  if [ "$dry_run" -eq 1 ]; then
    echo "+ $*"
  else
    "$@"
  fi
}

unset CDPATH
repo_dir="$(cd -- "$(dirname -- "$0")/.." && pwd)"
flake_ref=""

case "$(uname -s)" in
  Linux)
    flake_ref="${repo_dir}#nixos"
    rebuild_cmd="nixos-rebuild"
    ;;
  Darwin)
    flake_ref="${repo_dir}#mac"
    rebuild_cmd="darwin-rebuild"
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

echo "#########################################################################"
echo "#   Nix Update"
echo "#   Repo: ${repo_dir}"
echo "#   Flake: ${flake_ref}"

cd "${repo_dir}"
run nix flake update

if ! command -v "${rebuild_cmd}" >/dev/null 2>&1; then
  echo "Missing command: ${rebuild_cmd}"
  exit 1
fi

run sudo "${rebuild_cmd}" switch --flake "${flake_ref}"

echo "#########################################################################"
echo "#   Nix Update Complete"
