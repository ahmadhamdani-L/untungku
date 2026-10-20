"""Release guard regression checks; values are placeholders, never signing keys."""
import os
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
KEYS = ['ANDROID_KEYSTORE_BASE64', 'ANDROID_KEYSTORE_PASSWORD',
        'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD']


class ReleaseGuardTest(unittest.TestCase):
    def run_guard(self, signing=True, **options):
        env = {k: v for k, v in os.environ.items()
               if k not in KEYS + ['AD_CONFIG_PATH', 'CONFIRM_OWNER_ADS']}
        if signing:
            env.update(dict.fromkeys(KEYS, 'placeholder'))
        env.update(options)
        return subprocess.run(['python3', 'tool/validate_release.py'], cwd=ROOT,
                              env=env, capture_output=True, text=True)

    def test_missing_signing_fails(self):
        result = self.run_guard(signing=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Missing signing configuration', result.stderr)

    def test_owner_requires_explicit_confirmation(self):
        result = self.run_guard(AD_CONFIG_PATH='config/admob-release.json')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('requires explicit confirmation', result.stderr)

    def test_confirmed_owner_and_offline_accepted(self):
        self.assertEqual(self.run_guard().returncode, 0)
        self.assertEqual(self.run_guard(AD_CONFIG_PATH='config/admob-release.json',
                                       CONFIRM_OWNER_ADS='true').returncode, 0)

    def test_unknown_profile_fails(self):
        self.assertNotEqual(self.run_guard(AD_CONFIG_PATH='/tmp/unknown.json').returncode, 0)


if __name__ == '__main__':
    unittest.main()
