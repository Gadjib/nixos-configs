"""Run with python3 -B -m unittest discover -s tests -p test_home_smb_network.py -v."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "modules/nixos/home-smb-network.sh"


class HomeNetworkTest(unittest.TestCase):
    def check_network(self, listing, allowed, error=False):
        with tempfile.TemporaryDirectory() as directory:
            mock = Path(directory) / "nmcli"
            mock.write_text(f"#!{shutil.which('python3')}\n" + '''import os, sys
assert sys.argv[1:] == ['--wait', '2', '--terse', '--escape', 'no', '--fields',
                       'ACTIVE,SSID', 'device', 'wifi', 'list', '--rescan', 'no']
print(os.environ['TEST_NETWORKS'])
sys.exit(int(os.environ['TEST_NM_ERROR']))
''')
            mock.chmod(0o755)
            env = dict(os.environ, PATH=directory, TEST_NETWORKS=listing,
                       TEST_NM_ERROR=str(int(error)))
            result = subprocess.run([shutil.which("bash"), "-euo", "pipefail", str(SCRIPT)],
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0 if allowed else 1, result.stderr)

    def test_home_prefix_and_case_sensitive_suffixes(self):
        for ssid in ("0xDEADBEEF", "0xDEADBEEF48", "0xDEADBEEF-5GHz", "0xDEADBEEF:guest"):
            with self.subTest(ssid=ssid):
                self.check_network("yes:" + ssid, True)

    def test_other_networks_and_near_matches(self):
        for ssid in ("Hotel", "deadbeef48", "0xdeadbeef48", "other0xDEADBEEF", "0xDEADBEE"):
            with self.subTest(ssid=ssid):
                self.check_network("yes:" + ssid, False)

    def test_home_visible_but_not_connected(self):
        self.check_network("no:0xDEADBEEF48\nyes:Hotel", False)

    def test_multiple_adapters(self):
        self.check_network("yes:Other\nno:0xDEADBEEF99\nyes:0xDEADBEEF48", True)

    def test_no_wifi_including_ethernet_only(self):
        self.check_network("", False)

    def test_nm_error_fails_closed_even_with_output(self):
        self.check_network("yes:0xDEADBEEF48", False, error=True)


if __name__ == "__main__":
    unittest.main()
