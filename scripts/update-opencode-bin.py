#!/usr/bin/env python3
"""Pin official binaries for every configured platform before evaluation."""

import base64
import json
from pathlib import Path
import re
import subprocess
import tempfile
import urllib.request


CHANNEL_API = "https://opencode.ai/update/api/latest/cli/npm"
RELEASE_API = "https://api.github.com/repos/anomalyco/opencode/releases/tags/v"
ASSETS = {
    "aarch64-darwin": "opencode-darwin-arm64.zip",
    # Baseline also works on older x86_64 CPUs without AVX2.
    "x86_64-linux": "opencode-linux-x64-baseline.tar.gz",
}
MANIFEST = Path(__file__).resolve().parents[1] / "pkgs/opencode-bin.json"


def release_info(release):
    tag = release["tag_name"]
    if release.get("draft") or release.get("prerelease") or not re.fullmatch(r"v\d+\.\d+\.\d+", tag):
        raise ValueError(f"Not a stable OpenCode release: {tag}")
    assets = {}
    for system, name in ASSETS.items():
        url = f"https://github.com/anomalyco/opencode/releases/download/{tag}/{name}"
        asset = next(asset for asset in release["assets"] if asset["name"] == name)
        if asset["browser_download_url"] != url:
            raise ValueError("Unexpected OpenCode release asset URL")
        assets[system] = {"url": url, "digest": asset.get("digest")}
    return tag[1:], assets


def asset_hash(asset):
    digest = asset["digest"]
    if digest:
        if not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
            raise ValueError("Invalid OpenCode release digest")
        # Nix verifies the archive against GitHub's published SHA-256 at fetch time.
        return "sha256-" + base64.b64encode(bytes.fromhex(digest[7:])).decode()
    result = subprocess.run(
        ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", asset["url"]],
        check=True, capture_output=True, text=True,
    )
    return json.loads(result.stdout)["hash"]


def update(manifest=MANIFEST):
    # GitHub's /releases/latest still points to V1. Follow the official V2 channel.
    request = urllib.request.Request(CHANNEL_API, headers={"User-Agent": "nix-config-updater"})
    with urllib.request.urlopen(request, timeout=60) as response:
        channel_version = json.load(response)["version"]
    if not re.fullmatch(r"\d+\.\d+\.\d+", channel_version) or int(channel_version.split(".")[0]) < 2:
        raise ValueError(f"Unexpected OpenCode channel version: {channel_version}")
    request = urllib.request.Request(RELEASE_API + channel_version, headers={"User-Agent": "nix-config-updater"})
    with urllib.request.urlopen(request, timeout=60) as response:
        version, assets = release_info(json.load(response))
    if version != channel_version:
        raise ValueError("OpenCode release does not match the official update channel")
    print(f"OpenCode: checking official release {version}", flush=True)
    pinned = {
        system: {"url": asset["url"], "hash": asset_hash(asset)}
        for system, asset in assets.items()
    }
    content = json.dumps({"version": version, "platforms": pinned}, indent=2) + "\n"
    if manifest.exists() and manifest.read_text() == content:
        print(f"OpenCode: already pinned to {version}")
        return
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=manifest.parent, delete=False) as output:
            temporary = Path(output.name)
            output.write(content)
        temporary.replace(manifest)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    print(f"OpenCode: pinned {version} in {manifest.name}")


if __name__ == "__main__":
    update()
