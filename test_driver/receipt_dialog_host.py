"""Dismiss three Android receipt test dialogs, then save a test PDF; run beside receipt_delivery_test.dart.

Usage: python3 test_driver/receipt_dialog_host.py /path/to/adb emulator-5554
Only use with the dedicated Untungku test emulator. No share target is selected.
"""
import subprocess
import sys
import time
import re
import xml.etree.ElementTree as ET

adb, serial = sys.argv[1:3]
closed = 0
deadline = time.monotonic() + 120
while time.monotonic() < deadline:
    output = subprocess.check_output(
        [adb, '-s', serial, 'shell', 'dumpsys', 'window'], text=True
    )
    focus = '\n'.join(line for line in output.splitlines() if 'mCurrentFocus=' in line)
    if 'documentsui' in focus or 'ChooserActivity' in focus:
        time.sleep(1)
        subprocess.check_call([adb, '-s', serial, 'shell', 'input', 'keyevent', '4'])
        closed += 1
        print(f'Dismissed receipt dialog {closed}/3', flush=True)
        if closed == 3:
            break
        time.sleep(1)
    time.sleep(0.5)
if closed != 3:
    raise SystemExit(f'Expected 3 receipt dialogs; dismissed {closed}')
while time.monotonic() < deadline:
    output = subprocess.check_output([adb, '-s', serial, 'shell', 'dumpsys', 'window'], text=True)
    focus = '\n'.join(line for line in output.splitlines() if 'mCurrentFocus=' in line)
    if 'documentsui' in focus:
        subprocess.run([adb, '-s', serial, 'shell', 'uiautomator', 'dump', '/sdcard/receipt-dialog.xml'], check=True, capture_output=True)
        xml = subprocess.check_output([adb, '-s', serial, 'shell', 'cat', '/sdcard/receipt-dialog.xml'], text=True)
        for node in ET.fromstring(xml).iter('node'):
            if node.get('text', '').upper() in {'SAVE', 'SIMPAN'} and node.get('enabled') == 'true':
                x1,y1,x2,y2 = map(int, re.findall(r'\d+', node.attrib['bounds']))
                subprocess.check_call([adb, '-s', serial, 'shell', 'input', 'tap', str((x1+x2)//2), str((y1+y2)//2)])
                print('Saved native receipt PDF', flush=True)
                sys.exit(0)
    time.sleep(.5)
raise SystemExit('Native receipt save button was not available')
