"""Build locally with external signing credentials; never copy keys into Git."""
import argparse
import base64
import json
import os
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--credentials', required=True, type=Path)
parser.add_argument('--owner-ads', action='store_true', help='Use the supplied AdMob IDs')
args = parser.parse_args()
credentials = json.loads(args.credentials.read_text())
key = Path(credentials['keystore_path']).expanduser().resolve()
profile = 'config/admob-release.json' if args.owner_ads else 'config/development.json'
config = json.loads(Path(profile).read_text())
env = os.environ.copy()
env.update({
    'ANDROID_KEYSTORE_PATH': str(key),
    'ANDROID_KEYSTORE_BASE64': base64.b64encode(key.read_bytes()).decode(),
    'ANDROID_KEYSTORE_PASSWORD': credentials['store_password'],
    'ANDROID_KEY_PASSWORD': credentials['key_password'],
    'ANDROID_KEY_ALIAS': credentials['alias'],
    'AD_CONFIG_PATH': profile,
    'CONFIRM_OWNER_ADS': 'true' if args.owner_ads else 'false',
    'ADMOB_ANDROID_APP_ID': config.get('ADMOB_ANDROID_APP_ID', 'ca-app-pub-3940256099942544~3347511713'),
})
subprocess.run(['python3', 'tool/validate_release.py'], env=env, check=True)
subprocess.run(['flutter', 'build', 'appbundle', '--release', '--no-pub',
                '--dart-define-from-file=' + profile], env=env, check=True)
print('Signed AAB: build/app/outputs/bundle/release/app-release.aab')
