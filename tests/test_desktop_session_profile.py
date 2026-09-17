"""Exercise the real session script in disposable homes, with no desktop bus.

Run: python3 -B -m unittest discover -s tests -v
The DEBUG trap kills bash at each mutation boundary. dconf, systemctl and
sync are substitutes; these tests check process interruption, not power loss.
"""
import os
from pathlib import Path
import shutil
import stat
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "home/ilya/desktop-session-profile.sh"
BASH = shutil.which("bash")
PYTHON = shutil.which("python3")
FILES = {
    "kdeglobals": ".config/kdeglobals",
    "kded5rc": ".config/kded5rc",
    "gtk3-settings": ".config/gtk-3.0/settings.ini",
    "gtk4-settings": ".config/gtk-4.0/settings.ini",
    "gtk4-css": ".config/gtk-4.0/gtk.css",
    "gtk4-dark-css": ".config/gtk-4.0/gtk-dark.css",
    "gtk4-assets": ".config/gtk-4.0/assets",
    "firefox-userchrome": ".mozilla/firefox/hyprland/chrome/userChrome.css",
}
DCONF = "[/]\ncolor-scheme='default'\n"


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def describe(path):
    if path.is_symlink():
        return ("link", os.readlink(path))
    if path.is_dir():
        return ("directory", sorted((p.name, describe(p)) for p in path.iterdir()))
    if path.exists():
        return ("file", path.read_bytes(), stat.S_IMODE(path.stat().st_mode))
    return None


class Fixture:
    def __init__(self, root):
        self.root = root
        self.home = root / "home"
        self.state = self.home / ".local/state/nixos-desktop-isolation"
        self.bin = root / "bin"
        self.bin.mkdir()
        self.runtime = root / "runtime"
        self.runtime.mkdir()
        write(self.state / "plasma-reset-v1", "already initialized\n")
        for key, relative in FILES.items():
            path = self.home / relative
            if key == "gtk4-assets":
                write(path / "nested/icon.svg", "original asset")
                (path / "alias.svg").symlink_to("nested/icon.svg")
            elif key == "gtk4-dark-css":
                path.parent.mkdir(parents=True, exist_ok=True)
                path.symlink_to("missing-original.css")
            elif key not in ("firefox-userchrome", "gtk4-settings"):
                write(path, f"Plasma {key}")
                path.chmod(0o640)
        self.original = {k: describe(self.home / p) for k, p in FILES.items()}
        self.hypr = self.home / ".config/.desktop-profiles/hyprland"
        sources = [
            self.home / ".config/.home-manager-kdeglobals",
            self.home / ".config/.home-manager-kded5rc",
            self.hypr / "gtk-3.0/settings.ini",
            self.hypr / "gtk-4.0/settings.ini",
            self.hypr / "gtk-4.0/gtk.css",
            self.hypr / "gtk-4.0/gtk-dark.css",
            self.hypr / "gtk-4.0/assets/icon.svg",
            self.hypr / "firefox/userChrome.css",
        ]
        for path in sources:
            write(path, "Hyprland settings")
        write(self.hypr / "dconf-interface.ini", "[/]\ncolor-scheme='prefer-dark'\n")
        write(root / "dconf-data", DCONF)
        dconf = self.bin / "dconf"
        write(dconf, f"#!{PYTHON}\n" + '''import os, sys
from pathlib import Path
p = Path(os.environ["AUDIT_DCONF"])
if sys.argv[1] == "dump":
    sys.stdout.write(p.read_text())
elif sys.argv[1] == "reset":
    p.write_text("")
elif sys.argv[1] == "load":
    p.write_text(sys.stdin.read())
else:
    raise SystemExit(2)
''')
        dconf.chmod(0o755)
        for name in ("systemctl", "sync"):
            path = self.bin / name
            write(path, f"#!{BASH}\nexit 0\n")
            path.chmod(0o755)
        hook = root / "fault-hook"
        write(hook, r'''set -T
fault_count=0
fault_boundary() {
  case "$BASH_COMMAND" in
    cp\ *|mv\ *|rm\ *|dconf\ *|touch\ *|install\ *|chmod\ *)
      fault_count=$((fault_count + 1))
      printf '%s\n' "$fault_count" >> "$AUDIT_TRACE"
      if [[ "$fault_count" == "${AUDIT_KILL_AT:-0}" ]]; then
        kill -KILL "$$"
      fi
      ;;
  esac
}
trap fault_boundary DEBUG
''')
        self.env = dict(os.environ, HOME=str(self.home), XDG_RUNTIME_DIR=str(self.runtime),
                        PATH=f"{self.bin}:{os.environ['PATH']}",
                        AUDIT_DCONF=str(root / "dconf-data"), AUDIT_TRACE=str(root / "trace"))
        self.hook = hook

    def run(self, mode, kill_at=0, trace=False):
        env = self.env.copy()
        env.pop("BASH_ENV", None)
        if trace or kill_at:
            env.update(BASH_ENV=str(self.hook), AUDIT_KILL_AT=str(kill_at))
        return subprocess.run([BASH, str(SCRIPT), mode], env=env, capture_output=True, text=True)

    def assert_plasma(self, test):
        test.assertEqual(self.original, {k: describe(self.home / p) for k, p in FILES.items()})
        test.assertEqual((self.root / "dconf-data").read_text(), DCONF)

    def legacy(self, kind):
        legacy = self.state / "active-hyprland"
        saved = legacy / "files"
        saved.mkdir(parents=True)
        for index, (key, relative) in enumerate(FILES.items()):
            live = self.home / relative
            # v1 interrupted save moved only the first two entries.
            if kind == "saving" and index >= 2:
                continue
            if live.exists() or live.is_symlink():
                shutil.move(str(live), str(saved / key))
            else:
                (saved / f"{key}.absent").touch()
            if kind != "saving":
                write(live, "Hyprland live settings")
        if kind != "saving":
            write(legacy / "dconf-interface.ini", DCONF)
            (legacy / ".active").touch()
            write(self.root / "dconf-data", "Hyprland dconf")
        if kind == "restoring":
            live = self.home / FILES["kdeglobals"]
            live.unlink()
            shutil.move(str(saved / "kdeglobals"), str(live))


class SessionRecoveryTest(unittest.TestCase):
    def ok(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)

    def exercise_faults(self, setup, mode, recovery):
        with tempfile.TemporaryDirectory(prefix="desktop-recovery-") as directory:
            fixture = Fixture(Path(directory))
            setup(fixture)
            self.ok(fixture.run(mode, trace=True))
            count = int((fixture.root / "trace").read_text().splitlines()[-1])
        for boundary in range(1, count + 1):
            with self.subTest(mode=mode, boundary=boundary):
                with tempfile.TemporaryDirectory(prefix="desktop-recovery-") as directory:
                    fixture = Fixture(Path(directory))
                    setup(fixture)
                    self.assertEqual(fixture.run(mode, kill_at=boundary).returncode, -9)
                    self.ok(fixture.run(recovery))
                    self.ok(fixture.run("plasma"))
                    fixture.assert_plasma(self)
        print(f"  {mode} -> {recovery}: {count} interruption points", flush=True)

    def test_interrupted_save_and_apply(self):
        self.exercise_faults(lambda f: None, "hyprland", "hyprland")

    def test_interrupted_save_and_apply_then_plasma(self):
        self.exercise_faults(lambda f: None, "hyprland", "plasma")

    def test_interrupted_restore(self):
        self.exercise_faults(lambda f: self.ok(f.run("hyprland")), "plasma", "plasma")

    def test_interrupted_restore_then_hyprland(self):
        self.exercise_faults(lambda f: self.ok(f.run("hyprland")), "plasma", "hyprland")

    def test_legacy_migration_faults(self):
        for kind in ("saving", "active", "restoring"):
            with self.subTest(legacy=kind):
                self.exercise_faults(lambda f: f.legacy(kind), "plasma", "plasma")

    def test_missing_source_preserves_plasma(self):
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            (fixture.hypr / "gtk-4.0/gtk.css").unlink()
            self.assertNotEqual(fixture.run("hyprland").returncode, 0)
            fixture.assert_plasma(self)
            self.ok(fixture.run("plasma"))

    def test_missing_snapshot_refuses_restore(self):
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            self.ok(fixture.run("hyprland"))
            (fixture.state / "session-v2/files/kdeglobals").unlink()
            before = describe(fixture.home / ".config/kdeglobals")
            self.assertNotEqual(fixture.run("plasma").returncode, 0)
            self.assertEqual(before, describe(fixture.home / ".config/kdeglobals"))

    def test_new_session_saves_new_plasma_settings(self):
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            self.ok(fixture.run("hyprland"))
            self.ok(fixture.run("plasma"))
            write(fixture.home / ".config/kdeglobals", "New Plasma")
            fixture.original["kdeglobals"] = describe(fixture.home / ".config/kdeglobals")
            self.ok(fixture.run("hyprland"))
            self.ok(fixture.run("plasma"))
            fixture.assert_plasma(self)

    def test_initial_reset_is_recoverable(self):
        def setup(fixture):
            (fixture.state / "plasma-reset-v1").unlink()

        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            setup(fixture)
            self.ok(fixture.run("plasma", trace=True))
            count = int((fixture.root / "trace").read_text().splitlines()[-1])
        for boundary in range(1, count + 1):
            with self.subTest(boundary=boundary):
                with tempfile.TemporaryDirectory() as directory:
                    fixture = Fixture(Path(directory))
                    setup(fixture)
                    self.assertEqual(fixture.run("plasma", kill_at=boundary).returncode, -9)
                    self.ok(fixture.run("plasma"))
                    snapshot = fixture.state / "initial-reset-v2"
                    for key, relative in FILES.items():
                        self.assertEqual(describe(snapshot / "files" / relative), fixture.original[key])
                    self.assertEqual((snapshot / "dconf-interface.ini").read_text(), DCONF)
                    self.assertEqual((fixture.root / "dconf-data").read_text(), "")
        print(f"  initial reset: {count} interruption points", flush=True)


if __name__ == "__main__":
    unittest.main()
