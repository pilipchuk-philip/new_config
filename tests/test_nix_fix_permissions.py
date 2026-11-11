import importlib.machinery
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


loader = importlib.machinery.SourceFileLoader(
    "nix_fix_permissions", str(Path(__file__).parents[1] / "scripts/nix-fix-permissions")
)
spec = importlib.util.spec_from_loader(loader.name, loader)
fix = importlib.util.module_from_spec(spec)
loader.exec_module(fix)


class NixFixPermissionsTests(unittest.TestCase):
    def test_standard_include_paths(self):
        for directive in ["@includedir", "#includedir"]:
            for path in ["/etc/sudoers.d", "/private/etc/sudoers.d"]:
                self.assertEqual(fix.included_directory(f"{directive} {path}\n"), Path(path))

    def test_missing_include_is_not_modified(self):
        with self.assertRaises(RuntimeError):
            fix.included_directory("Defaults env_reset\n")

    def test_no_arguments_requests_sudo_with_correct_home(self):
        with patch.object(fix.sys, "argv", ["nix-fix-permissions"]), \
             patch.object(fix.os, "geteuid", return_value=501), \
             patch.object(fix.Path, "is_file", return_value=True), \
             patch.object(fix.os, "execv") as execute:
            fix.main()
            sudo, arguments = execute.call_args.args
            self.assertEqual(arguments[:3], [sudo, "-H", "--"])
            self.assertEqual(arguments[3], fix.sys.executable)
            self.assertEqual(arguments[4], str(Path(fix.__file__).resolve()))

    def test_arguments_are_rejected(self):
        with patch.object(fix.sys, "argv", ["nix-fix-permissions", "nix"]), \
             patch.object(fix.os, "execv") as execute:
            with self.assertRaises(SystemExit):
                fix.main()
            execute.assert_not_called()

    def test_validation_preserves_diagnostics_and_stage(self):
        result = subprocess.CompletedProcess([], 1, stdout="/etc/sudoers: parsed OK\n",
                                             stderr="visudo: example permission error\n")
        with patch.object(fix.subprocess, "run", return_value=result):
            with self.assertRaises(RuntimeError) as error:
                fix.validate("/usr/sbin/visudo", stage="До изменений")
            for detail in ["До изменений", "кодом 1", "parsed OK", "example permission error"]:
                self.assertIn(detail, str(error.exception))

    def test_initial_validation_failure_does_not_modify_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with self.assertRaises(RuntimeError):
                self.run_install(root, RuntimeError("existing config invalid"))
            self.assertEqual(list((root / "sudoers.d").iterdir()), [])

    def test_nix_darwin_readonly_mode_uses_full_syntax_and_owner_check(self):
        first = subprocess.CompletedProcess([], 1, stdout="/private/etc/sudoers: parsed OK\n",
            stderr="/private/etc/sudoers.d/10-nix-darwin-extra-config: bad permissions, should be mode 0440\n")
        success = subprocess.CompletedProcess([], 0, stdout="parsed OK", stderr="")
        with patch.object(fix, "readonly_nix_include", return_value=True) as check, \
             patch.object(fix.subprocess, "run", side_effect=[first, success]) as run:
            fix.validate("visudo")
            check.assert_called_once_with("/private/etc/sudoers.d/10-nix-darwin-extra-config")
            self.assertEqual(run.call_args.args[0], ["visudo", "-c", "-O", "-f", "/etc/sudoers"])

    def test_nix_darwin_exception_does_not_hide_other_errors(self):
        mode_error = "/etc/sudoers.d/10-nix-darwin-extra-config: bad permissions, should be mode 0440\n"
        for error, trusted in [(mode_error, False), (mode_error + "syntax error\n", True),
                               (mode_error.replace("10-nix-darwin-extra-config", "other"), True)]:
            with self.subTest(error=error, trusted=trusted), \
                 patch.object(fix, "readonly_nix_include", return_value=trusted), \
                 patch.object(fix.subprocess, "run", return_value=subprocess.CompletedProcess(
                     [], 1, stdout="", stderr=error)) as run:
                with self.assertRaises(RuntimeError):
                    fix.validate("visudo")
                self.assertEqual(run.call_count, 1)

    def test_nix_darwin_fallback_still_rejects_syntax_errors(self):
        first = subprocess.CompletedProcess([], 1, stdout="", stderr=
            "/etc/sudoers.d/10-nix-darwin-extra-config: bad permissions, should be mode 0440\n")
        failed = subprocess.CompletedProcess([], 1, stdout="", stderr="syntax error")
        with patch.object(fix, "readonly_nix_include", return_value=True), \
             patch.object(fix.subprocess, "run", side_effect=[first, failed]):
            with self.assertRaisesRegex(RuntimeError, "syntax error"):
                fix.validate("visudo")

    def test_rule_validation_failure_removes_temporary_file(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with self.assertRaises(RuntimeError):
                self.run_install(root, [None, RuntimeError("invalid rule")])
            self.assertEqual(list((root / "sudoers.d").iterdir()), [])

    def run_install(self, root, failure=None):
        sudoers = root / "sudoers"
        sudoers.write_text("original sudoers\n")
        directory = root / "sudoers.d"
        directory.mkdir(exist_ok=True)
        original_lstat = fix.Path.lstat

        def root_stat(path):
            info = original_lstat(path)
            return type("RootStat", (), {"st_uid": 0, "st_mode": info.st_mode})()

        with patch.object(fix, "included_directory", return_value=directory), \
             patch.object(fix.Path, "lstat", root_stat), \
             patch.object(fix, "validate", side_effect=failure) as validate:
            fix.install(sudoers, "/usr/sbin/visudo")
            return validate

    def test_install_validates_before_and_after_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            validate = self.run_install(root)
            self.assertEqual(validate.call_count, 3)
            destination = root / "sudoers.d/99-nix-fix-permissions"
            self.assertEqual(destination.read_text(), fix.RULE)
            self.assertEqual(destination.stat().st_mode & 0o777, 0o440)
            self.run_install(root)
            self.assertEqual((root / "sudoers").read_text(), "original sudoers\n")

    def test_failed_full_validation_removes_only_new_file(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with self.assertRaises(RuntimeError):
                self.run_install(root, [None, None, RuntimeError("invalid")])
            self.assertEqual(list((root / "sudoers.d").iterdir()), [])
            self.assertEqual((root / "sudoers").read_text(), "original sudoers\n")

    def test_existing_unknown_file_is_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            directory = root / "sudoers.d"
            directory.mkdir()
            destination = directory / "99-nix-fix-permissions"
            destination.write_text("user configuration\n")
            with self.assertRaises(RuntimeError):
                self.run_install(root)
            self.assertEqual(destination.read_text(), "user configuration\n")


if __name__ == "__main__":
    unittest.main()
