"""Exercise concurrent screenshot requests and cancellation without a compositor."""
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'home/ilya/hypr/screenshot.sh'


class ScreenshotTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = dict(os.environ, XDG_RUNTIME_DIR=str(self.root),
                        PATH=f'{self.root}:{os.environ["PATH"]}')
        mocks = {
            'slurp': 'touch "$XDG_RUNTIME_DIR/selecting"\n'
                     'while test -e "$XDG_RUNTIME_DIR/hold"; do sleep 0.02; done\n'
                     'test ! -e "$XDG_RUNTIME_DIR/cancel" || exit 1\n'
                     'echo "10,20 30x40"',
            'grim': 'test ! -e "$XDG_RUNTIME_DIR/fail" || exit 1\n'
                    'echo PNG > "${@: -1}"\n'
                    'echo capture >> "$XDG_RUNTIME_DIR/captures"',
            'wl-copy': 'cat > "$XDG_RUNTIME_DIR/clipboard"',
            'swappy': 'touch "$XDG_RUNTIME_DIR/editing"\n'
                      'while test -e "$XDG_RUNTIME_DIR/hold"; do sleep 0.02; done',
        }
        for name, body in mocks.items():
            p = self.root / name
            p.write_text('#!/usr/bin/env bash\nset -eu\n' + body + '\n')
            p.chmod(0o755)
        (self.root / 'clipboard').write_text('original')

    def run_shot(self, area='area', destination='clipboard'):
        return subprocess.run(['bash', str(SCRIPT), area, destination],
                              env=self.env, timeout=3)

    def assert_clean(self):
        self.assertEqual(list(self.root.glob('hyprland-screenshot.*.png')), [])

    def test_cancel_and_failure_preserve_clipboard(self):
        for marker in ['cancel', 'fail']:
            with self.subTest(marker=marker):
                (self.root / marker).touch()
                result = self.run_shot()
                self.assertEqual(result.returncode, 0 if marker == 'cancel' else 1)
                self.assertEqual((self.root / 'clipboard').read_text(), 'original')
                self.assert_clean()
                (self.root / marker).unlink()
        self.assertEqual(self.run_shot().returncode, 0)
        self.assertEqual((self.root / 'clipboard').read_text(), 'PNG\n')

    def test_all_bindings_share_lock_during_selection_and_editing(self):
        for phase, mode, dest in [('selecting', 'area', 'clipboard'),
                                  ('editing', 'screen', 'editor')]:
            with self.subTest(phase=phase):
                (self.root / 'hold').touch()
                proc = subprocess.Popen(['bash', str(SCRIPT), mode, dest], env=self.env)
                try:
                    deadline = time.monotonic() + 3
                    while not (self.root / phase).exists():
                        self.assertLess(time.monotonic(), deadline)
                        time.sleep(0.02)
                    before = (self.root / 'captures').read_text() if (self.root / 'captures').exists() else ''
                    for area in ['area', 'screen']:
                        for target in ['clipboard', 'editor']:
                            self.assertEqual(self.run_shot(area, target).returncode, 0)
                    after = (self.root / 'captures').read_text() if (self.root / 'captures').exists() else ''
                    self.assertEqual(before, after)
                finally:
                    (self.root / 'hold').unlink()
                    proc.wait(timeout=3)
                self.assertEqual(proc.returncode, 0)
                self.assert_clean()
                self.assertEqual(self.run_shot('screen').returncode, 0)


if __name__ == '__main__':
    unittest.main()
