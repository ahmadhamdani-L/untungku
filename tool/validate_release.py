"""Validate signing inputs and the explicit ad profile before CI release builds."""
import json
import os
from pathlib import Path
import re
import sys

required = ['ANDROID_KEYSTORE_BASE64', 'ANDROID_KEYSTORE_PASSWORD',
            'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD']
missing = [key for key in required if not os.environ.get(key)]
if missing:
    sys.exit('Missing signing configuration: ' + ', '.join(missing))
profile = Path(os.environ.get('AD_CONFIG_PATH', 'config/development.json'))
allowed = {Path('config/development.json'), Path('config/google-test.json'),
           Path('config/admob-release.json')}
if profile not in allowed:
    sys.exit('Unknown advertising profile')
config = json.loads(profile.read_text())
if config.get('ADMOB_ENABLED') and not config.get('ADMOB_USE_MOCK', True):
    app_id = config.get('ADMOB_ANDROID_APP_ID', 'ca-app-pub-3940256099942544~3347511713')
    if not re.fullmatch(r'ca-app-pub-\d{16}~\d{10}', app_id):
        sys.exit('Invalid AdMob Android app ID')
    publisher = app_id.split('~')[0]
    for key in ['ADMOB_BANNER_AD_UNIT_ID', 'ADMOB_INTERSTITIAL_AD_UNIT_ID',
                'ADMOB_REWARDED_AD_UNIT_ID']:
        unit = config.get(key, '')
        if not re.fullmatch(r'ca-app-pub-\d{16}/\d{10}', unit):
            sys.exit('Invalid ad unit: ' + key)
        if unit.split('/')[0] != publisher:
            sys.exit('Ad unit publisher does not match app ID: ' + key)
    if profile.name == 'admob-release.json':
        if os.environ.get('CONFIRM_OWNER_ADS') != 'true':
            sys.exit('Owner ad profile requires explicit confirmation; test ads first.')
        if publisher != 'ca-app-pub-6953774620667597':
            sys.exit('Owner ad profile publisher changed')
print('Signing inputs and selected ad profile valid. No Play publication is performed.')
