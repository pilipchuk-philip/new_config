import base64
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "update_opencode_bin", Path(__file__).parents[1] / "scripts/update-opencode-bin.py"
)
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


def release():
    return {
        "tag_name": "v2.3.0",
        "draft": False,
        "prerelease": False,
        "assets": [
            {
                "name": name,
                "browser_download_url": f"https://github.com/anomalyco/opencode/releases/download/v2.3.0/{name}",
                "digest": "sha256:" + "ab" * 32,
            }
            for name in updater.ASSETS.values()
        ],
    }


def response(value):
    return io.BytesIO(json.dumps(value).encode())


class UpdateOpencodeBinTests(unittest.TestCase):
    def test_both_platforms_use_versioned_urls(self):
        version, assets = updater.release_info(release())
        self.assertEqual(version, "2.3.0")
        self.assertEqual(set(assets), {"aarch64-darwin", "x86_64-linux"})
        self.assertTrue(assets["x86_64-linux"]["url"].endswith("-baseline.tar.gz"))

    def test_unstable_or_unexpected_releases_are_rejected(self):
        for changes in [{"draft": True}, {"prerelease": True}, {"tag_name": "v2.3.0-beta"}]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                updater.release_info({**release(), **changes})
        invalid = release()
        invalid["assets"][0]["browser_download_url"] = "https://example.com/untrusted.zip"
        with self.assertRaises(ValueError):
            updater.release_info(invalid)

    def test_digest_converted_to_nix_sri_without_download(self):
        with patch.object(updater.subprocess, "run") as run:
            hashed = updater.asset_hash({"digest": "sha256:" + "ab" * 32})
        self.assertEqual(hashed, "sha256-" + base64.b64encode(bytes.fromhex("ab" * 32)).decode())
        run.assert_not_called()

    def test_missing_digest_prefetches_archive(self):
        fetched = subprocess.CompletedProcess([], 0, stdout='{"hash":"sha256-example"}')
        with patch.object(updater.subprocess, "run", return_value=fetched) as run:
            self.assertEqual(updater.asset_hash({"digest": None, "url": "https://example.com/a"}), "sha256-example")
        self.assertEqual(run.call_args.args[0][-1], "https://example.com/a")
        self.assertTrue(run.call_args.kwargs["check"])

    def test_invalid_published_digest_is_not_ignored(self):
        with self.assertRaises(ValueError):
            updater.asset_hash({"digest": "sha256:broken"})

    def test_update_uses_official_v2_channel_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as temporary:
            manifest = Path(temporary) / "release.json"
            modified = None
            for _ in range(2):
                responses = [response({"version": "2.3.0"}), response(release())]
                with patch.object(updater.urllib.request, "urlopen", side_effect=responses) as fetch:
                    updater.update(manifest)
                self.assertEqual(fetch.call_args_list[0].args[0].full_url, updater.CHANNEL_API)
                self.assertTrue(fetch.call_args_list[1].args[0].full_url.endswith("/tags/v2.3.0"))
                if modified is not None:
                    self.assertEqual(manifest.stat().st_mtime_ns, modified)
                modified = manifest.stat().st_mtime_ns
            self.assertEqual(json.loads(manifest.read_text())["version"], "2.3.0")

    def test_failure_preserves_existing_manifest(self):
        with tempfile.TemporaryDirectory() as temporary:
            manifest = Path(temporary) / "release.json"
            manifest.write_text("existing lock\n")
            for result in [{"version": "1.19.5"}, {"version": "2.3.0-beta"}]:
                with patch.object(updater.urllib.request, "urlopen", return_value=response(result)):
                    with self.assertRaises(ValueError):
                        updater.update(manifest)
                self.assertEqual(manifest.read_text(), "existing lock\n")
            with patch.object(updater.urllib.request, "urlopen", side_effect=OSError("offline")):
                with self.assertRaises(OSError):
                    updater.update(manifest)
            self.assertEqual(manifest.read_text(), "existing lock\n")

    def test_missing_asset_or_failed_prefetch_preserves_lock(self):
        incomplete = release()
        incomplete["assets"].pop()
        missing_digest = release()
        missing_digest["assets"][1]["digest"] = None
        with tempfile.TemporaryDirectory() as temporary:
            manifest = Path(temporary) / "release.json"
            manifest.write_text("existing lock\n")
            for published in [incomplete, missing_digest]:
                responses = [response({"version": "2.3.0"}), response(published)]
                with patch.object(updater.urllib.request, "urlopen", side_effect=responses):
                    with patch.object(updater.subprocess, "run", side_effect=subprocess.CalledProcessError(1, "nix")):
                        with self.assertRaises((StopIteration, subprocess.CalledProcessError)):
                            updater.update(manifest)
                self.assertEqual(manifest.read_text(), "existing lock\n")


if __name__ == "__main__":
    unittest.main()
