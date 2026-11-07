"""Verify locally signed Android artifacts without opening signing credentials.

This does not approve a Play version code or publish anything.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile

parser = argparse.ArgumentParser()
parser.add_argument('--apk', type=Path, required=True)
parser.add_argument('--aab', type=Path, required=True)
parser.add_argument('--certificate', type=Path, required=True)
parser.add_argument('--java-home', type=Path, required=True)
parser.add_argument('--build-tools', type=Path, required=True)
parser.add_argument('--bundletool', type=Path, required=True)
parser.add_argument('--profile', type=Path, default=Path('config/admob-release.json'))
parser.add_argument('--report', type=Path, required=True)
parser.add_argument('--play-inventory-evidence', type=Path)
args = parser.parse_args()
env = os.environ.copy()
env['JAVA_HOME'] = str(args.java_home)

def run(command, **kwargs):
    return subprocess.check_output([str(item) for item in command], env=env, **kwargs)

def require(condition, message):
    if not condition:
        raise SystemExit(message)

expected_cert = hashlib.sha256(run(['openssl', 'x509', '-in', args.certificate, '-outform', 'DER'])).hexdigest()
apk_signature = run([args.build_tools / 'apksigner', 'verify', '--print-certs', args.apk], text=True)
match = re.search(r'Signer #1 certificate SHA-256 digest: (\w+)', apk_signature)
require(match and match[1].lower() == expected_cert, 'APK upload certificate does not match')
require('Signer #2' not in apk_signature, 'Unexpected extra APK signer')
jar_result = run([args.java_home / 'bin/jarsigner', '-J-Duser.language=en', '-verify', args.aab], stderr=subprocess.STDOUT, text=True)
require('jar verified.' in jar_result, 'AAB JAR signature verification failed')
with tempfile.TemporaryDirectory(prefix='untungku-public-cert-') as temp:
    with zipfile.ZipFile(args.aab) as bundle:
        signatures = [name for name in bundle.namelist() if name.startswith('META-INF/') and name.endswith('.RSA')]
        require(len(signatures) == 1, 'Expected exactly one AAB RSA signature')
        signature = Path(temp) / 'certificate.p7b'
        signature.write_bytes(bundle.read(signatures[0]))
    public_pem = run(['openssl', 'pkcs7', '-inform', 'DER', '-in', signature, '-print_certs'])
    pem_path = Path(temp) / 'certificate.pem'
    pem_path.write_bytes(public_pem)
    actual = hashlib.sha256(run(['openssl', 'x509', '-in', pem_path, '-outform', 'DER'])).hexdigest()
    require(actual == expected_cert, 'AAB upload certificate does not match')

manifest = run([args.java_home / 'bin/java', '-jar', args.bundletool, 'dump', 'manifest', '--bundle=' + str(args.aab)], text=True)
root = ET.fromstring(manifest)
ns = '{http://schemas.android.com/apk/res/android}'
package = root.attrib.get('package')
require(package == 'id.untungku.untungku_pro', 'Application identity changed')
version = root.attrib[ns + 'versionName']
code = int(root.attrib[ns + 'versionCode'])
sdk = root.find('uses-sdk')
require(sdk is not None and int(sdk.attrib[ns + 'minSdkVersion']) == 24 and int(sdk.attrib[ns + 'targetSdkVersion']) == 36, 'SDK configuration changed')
permissions = {p.attrib[ns + 'name']: p.attrib for p in root.findall('uses-permission')}
for permission in ['CAMERA', 'BLUETOOTH_CONNECT', 'INTERNET']:
    require('android.permission.' + permission in permissions, 'Missing permission: ' + permission)
for permission in ['BLUETOOTH', 'BLUETOOTH_ADMIN']:
    require(permissions['android.permission.' + permission].get(ns + 'maxSdkVersion') == '30', 'Legacy Bluetooth permission must be bounded')
features = {f.attrib.get(ns + 'name'): f.attrib.get(ns + 'required') for f in root.findall('uses-feature')}
for feature in ['camera', 'bluetooth']:
    require(features.get('android.hardware.' + feature) == 'false', 'Hardware must remain optional: ' + feature)
application = root.find('application')
require(application.attrib.get(ns + 'allowBackup') == 'false', 'Android application backup must be disabled')
metadata = {m.attrib.get(ns + 'name'): m.attrib.get(ns + 'value') for m in application.findall('meta-data')}
profile = json.loads(args.profile.read_text())
require(metadata.get('com.google.android.gms.ads.APPLICATION_ID') == profile['ADMOB_ANDROID_APP_ID'], 'AdMob application ID does not match explicit profile')
activity = next(a for a in application.findall('activity') if a.attrib.get(ns + 'name', '').endswith('MainActivity'))
require(activity.attrib.get(ns + 'exported') == 'true', 'Launcher activity must be exported')

badging = run([args.build_tools / 'aapt', 'dump', 'badging', args.apk], text=True)
require(f"name='{package}'" in badging and f"versionCode='{code}'" in badging and f"versionName='{version}'" in badging, 'APK/AAB identity or versions differ')
apk_xml = run([args.build_tools / 'aapt', 'dump', 'xmltree', args.apk, 'AndroidManifest.xml'], text=True)
require(profile['ADMOB_ANDROID_APP_ID'] in apk_xml, 'APK AdMob application ID does not match profile')
with zipfile.ZipFile(args.apk) as apk:
    compiled = apk.read('lib/arm64-v8a/libapp.so')
    for key in ['ADMOB_BANNER_AD_UNIT_ID', 'ADMOB_INTERSTITIAL_AD_UNIT_ID', 'ADMOB_REWARDED_AD_UNIT_ID', 'ADMOB_NATIVE_AD_UNIT_ID', 'ADMOB_APP_OPEN_AD_UNIT_ID']:
        value = profile[key]
        require(value.encode() in compiled or value.encode('utf-16le') in compiled, 'Active ad unit does not match explicit profile: ' + key)
    for name in apk.namelist():
        require(not name.startswith('assets/flutter_assets/test/'), 'Test fixtures packaged in APK')
        if re.fullmatch(r'classes\d*\.dex', name):
            require(b'IntegrationTestPlugin' not in apk.read(name), 'Integration-test plugin leaked into release APK')

source_hash = hashlib.sha256()
source_files = sorted([*Path('lib').rglob('*.dart'), Path('pubspec.yaml'), Path('pubspec.lock'), Path('android/app/src/main/AndroidManifest.xml'), Path('android/app/src/main/kotlin/id/untungku/untungku_pro/MainActivity.kt'), Path('android/app/build.gradle.kts'), args.profile, *Path('android/app/src/main/res').rglob('*.xml'), *Path('android/app/src/main/res').rglob('*.png'), *Path('assets/branding').glob('*.png'), Path('assets/legal/privacy-id.json')])
for path in source_files:
    source_hash.update(str(path).encode() + b'\0' + path.read_bytes() + b'\0')
play_confirmed = False
if args.play_inventory_evidence:
    evidence = json.loads(args.play_inventory_evidence.read_text())
    require(evidence['package'] == package and evidence['allPagesInspected'] and evidence['selectedNextVersionCode'] == code and code > max(evidence['observedVersionCodes']), 'Play inventory evidence does not establish this candidate version code')
    play_confirmed = True
report = {'sourceSha256': source_hash.hexdigest(), 'package': package, 'versionName': version, 'versionCode': code,
          'minSdk': 24, 'targetSdk': 36, 'uploadCertificateMatches': True,
          'apkAndAabSignaturesVerified': True, 'productionAdmobAppIdMatchesProfile': True,
          'activeBannerInterstitialUnitsMatchProfile': True,
          'allFiveAdUnitsMatchProfile': True,
          'bluetoothCameraOptional': True, 'secureStorageBackupDisabled': True,
          'integrationPluginAbsentFromRelease': True, 'playVersionCodeConfirmedUnused': play_confirmed,
          'releaseReady': False, 'publicationPerformed': False,
          'artifacts': {str(path): {'bytes': path.stat().st_size,
                        'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
                        for path in [args.apk, args.aab]}}
args.report.parent.mkdir(parents=True, exist_ok=True)
args.report.write_text(json.dumps(report, indent=2) + '\n')
print('Local APK/AAB signatures, identity, SDK, permissions and explicit AdMob app profile verified.')
print('Hardware acceptance remains unverified; consult the release report for the actual submission status.')
