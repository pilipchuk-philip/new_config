import importlib.machinery
import importlib.util
from pathlib import Path
import plistlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch


loader = importlib.machinery.SourceFileLoader(
    "nix_fix_darwin_socket",
    str(Path(__file__).parents[1] / "scripts/nix-fix-darwin-socket"),
)
spec = importlib.util.spec_from_loader(loader.name, loader)
fix = importlib.util.module_from_spec(spec)
loader.exec_module(fix)


def result(code=0, stderr=""):
    return subprocess.CompletedProcess([], code, stdout="", stderr=stderr)


class NixFixDarwinSocketTests(unittest.TestCase):
    def test_non_darwin_does_not_request_sudo(self):
        with patch.object(fix.sys, "argv", ["nix-fix-darwin-socket"]), \
             patch.object(fix.sys, "platform", "linux"), \
             patch.object(fix.os, "execv") as execute:
            with self.assertRaisesRegex(RuntimeError, "macOS"):
                fix.main()
            execute.assert_not_called()

    def test_sudo_sets_home_and_uses_current_python(self):
        with patch.object(fix.sys, "argv", ["nix-fix-darwin-socket"]), \
             patch.object(fix.sys, "platform", "darwin"), \
             patch.object(fix.os, "geteuid", return_value=501), \
             patch.object(fix.os, "execv") as execute:
            fix.main()
            execute.assert_called_once_with("/usr/bin/sudo", [
                "/usr/bin/sudo", "-H", "--", fix.sys.executable,
                str(Path(fix.__file__).resolve()),
            ])

    def test_arguments_rejected_before_changes(self):
        with patch.object(fix.sys, "argv", ["nix-fix-darwin-socket", "anything"]), \
             patch.object(fix.os, "execv") as execute:
            with self.assertRaises(SystemExit):
                fix.main()
            execute.assert_not_called()

    def test_unloaded_service_is_enabled_bootstrapped_and_started(self):
        with patch.object(fix, "validate_plist"), \
             patch.object(fix, "checked") as checked, \
             patch.object(fix, "run", return_value=result(113)), \
             patch.object(fix, "ping", return_value=result()):
            fix.repair("/bin/nix")
            self.assertEqual([c.args[0] for c in checked.call_args_list], [
                [fix.LAUNCHCTL, "enable", fix.SERVICE],
                [fix.LAUNCHCTL, "bootstrap", "system", str(fix.PLIST)],
                [fix.LAUNCHCTL, "kickstart", "-k", fix.SERVICE],
            ])

    def test_healthy_service_is_not_restarted(self):
        with patch.object(fix, "validate_plist"), \
             patch.object(fix, "checked") as checked, \
             patch.object(fix, "run", return_value=result()), \
             patch.object(fix, "ping", return_value=result()):
            fix.repair("/bin/nix")
            checked.assert_called_once_with([fix.LAUNCHCTL, "enable", fix.SERVICE])

    def test_unhealthy_loaded_service_restarts_and_waits_for_protocol(self):
        with patch.object(fix, "validate_plist"), \
             patch.object(fix, "checked") as checked, \
             patch.object(fix, "run", return_value=result()), \
             patch.object(fix, "ping", side_effect=[result(1), result(1), result()]), \
             patch.object(fix.time, "sleep") as sleep:
            fix.repair("/bin/nix")
            self.assertEqual(checked.call_count, 2)
            checked.assert_called_with([fix.LAUNCHCTL, "kickstart", "-k", fix.SERVICE])
            sleep.assert_called_once_with(1)

    def test_persistent_failure_preserves_diagnostics(self):
        with patch.object(fix, "validate_plist"), \
             patch.object(fix, "checked"), \
             patch.object(fix, "run", return_value=result()), \
             patch.object(fix, "ping", return_value=result(1, "Connection refused")), \
             patch.object(fix.time, "sleep"):
            with self.assertRaisesRegex(RuntimeError, "Connection refused"):
                fix.repair("/bin/nix")

    def test_validation_failure_prevents_launchctl(self):
        with patch.object(fix, "validate_plist", side_effect=RuntimeError("bad plist")), \
             patch.object(fix, "checked") as checked, \
             patch.object(fix, "run") as run:
            with self.assertRaisesRegex(RuntimeError, "bad plist"):
                fix.repair("/bin/nix")
            checked.assert_not_called()
            run.assert_not_called()

    def test_launchctl_failure_stops_repair(self):
        with patch.object(fix, "validate_plist"), \
             patch.object(fix, "run", return_value=result(5, "Input/output error")) as run:
            with self.assertRaisesRegex(RuntimeError, "Input/output error"):
                fix.repair("/bin/nix")
            self.assertEqual(run.call_count, 1)

    def test_ping_uses_explicit_socket(self):
        with patch.object(fix, "run") as run:
            fix.ping("/bin/nix")
            self.assertEqual(run.call_args.args[0][-2:], ["--store", fix.STORE])

    def test_plist_validation(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "daemon.plist"
            for config, uid, mode, valid in [
                ({"Label": fix.LABEL, "KeepAlive": True}, 0, 0o100644, True),
                ({"Label": fix.LABEL, "RunAtLoad": True}, 0, 0o100644, True),
                ({"Label": "other", "KeepAlive": True}, 0, 0o100644, False),
                ({"Label": fix.LABEL}, 0, 0o100644, False),
                ({"Label": fix.LABEL, "KeepAlive": True}, 501, 0o100644, False),
                ({"Label": fix.LABEL, "KeepAlive": True}, 0, 0o100666, False),
            ]:
                with self.subTest(config=config, uid=uid, mode=mode):
                    path.write_bytes(plistlib.dumps(config))
                    info = type("Info", (), {"st_uid": uid, "st_mode": mode})()
                    with patch.object(fix.Path, "stat", return_value=info):
                        if valid:
                            fix.validate_plist(path)
                        else:
                            with self.assertRaises(RuntimeError):
                                fix.validate_plist(path)


if __name__ == "__main__":
    unittest.main()
