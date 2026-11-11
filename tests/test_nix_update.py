import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).parents[1] / "scripts/nix-update"


class NixUpdateTests(unittest.TestCase):
    def run_update(self, target, *, dry_run=False, fail_check=False, fail_update=False):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            script = root / "nix-update"
            script.write_text(SCRIPT.read_text())
            helpers = {
                "nix-repo": '#!/bin/sh\nprintf "%s\\n" "$TEST_REPO"\n',
                "nix-target": '#!/bin/sh\nprintf "%s\\n" "$TEST_TARGET"\n',
                "nix": (
                    '#!/bin/sh\nprintf "nix %s\\n" "$*" >> "$TEST_LOG"\n'
                    'if [ "$*" = "flake check --all-systems --no-build --no-write-lock-file" ]; then\n'
                    '  exit "$TEST_CHECK_STATUS"\n'
                    'fi\n'
                ),
                "sudo": '#!/bin/sh\nprintf "sudo %s\\n" "$*" >> "$TEST_LOG"\n',
                "nixos-rebuild": "#!/bin/sh\nexit 99\n",
                "python3": (
                    '#!/bin/sh\nprintf "python3 %s\\n" "$*" >> "$TEST_LOG"\n'
                    'exit "$TEST_UPDATE_STATUS"\n'
                ),
            }
            for name, content in helpers.items():
                helper = root / name
                helper.write_text(content)
                helper.chmod(0o755)
            log = root / "commands.log"
            result = subprocess.run(
                ["/bin/sh", str(script), *(["--dry-run"] if dry_run else [])],
                env={
                    **os.environ,
                    "PATH": f"{root}:/usr/bin:/bin",
                    "TEST_REPO": str(root),
                    "TEST_TARGET": target,
                    "TEST_LOG": str(log),
                    "TEST_CHECK_STATUS": "1" if fail_check else "0",
                    "TEST_UPDATE_STATUS": "1" if fail_update else "0",
                },
                capture_output=True,
                text=True,
            )
            return result, log.read_text() if log.exists() else ""

    def test_build_logs_enabled_for_every_target(self):
        for target, command in [
            ("darwin:mac-work", "-- switch --print-build-logs --flake"),
            ("nixos:nixos", "nixos-rebuild switch --print-build-logs --flake"),
            ("home-manager:ubuntu-desktop", "-- switch --print-build-logs --flake"),
        ]:
            with self.subTest(target=target):
                result, log = self.run_update(target)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(command, log)
                self.assertLess(log.index("flake update"), log.index("flake check"))
                self.assertLess(log.index("flake update"), log.index("update-opencode-bin.py"))
                self.assertLess(log.index("update-opencode-bin.py"), log.index("flake check"))
                self.assertLess(log.index("flake check"), log.index(command))

    def test_dry_run_does_not_run_update_or_activation(self):
        result, log = self.run_update("darwin:mac-work", dry_run=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(log, "")
        self.assertIn("-- switch --print-build-logs --flake", result.stdout)

    def test_failed_validation_prevents_activation(self):
        result, log = self.run_update("darwin:mac-work", fail_check=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("switch", log)

    def test_failed_binary_update_prevents_activation(self):
        result, log = self.run_update("darwin:mac-work", fail_update=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("flake check", log)
        self.assertNotIn("switch", log)


if __name__ == "__main__":
    unittest.main()
