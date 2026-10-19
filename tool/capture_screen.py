"""Capture the actual Android screen as a lossless, opaque store-listing PNG.

Only an entirely opaque alpha channel is removed. Pixels are not cropped,
resized, decorated, or generated. Select the desired screen before running.
"""
import argparse
import io
import os
from pathlib import Path
import shutil
import subprocess
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
parser.add_argument('--device', default='emulator-5554')
parser.add_argument('--adb', default=shutil.which('adb') or str(Path.home() / 'Library/Android/sdk/platform-tools/adb'))
args = parser.parse_args()
raw = subprocess.run([args.adb, '-s', args.device, 'exec-out', 'screencap', '-p'], check=True, capture_output=True).stdout
screen = Image.open(io.BytesIO(raw))
if screen.mode == 'RGBA' and screen.getchannel('A').getextrema() != (255, 255):
    raise SystemExit('Screen has transparency; refusing to alter rendered pixels.')
w, h = screen.size
if min(w, h) < 320 or max(w, h) > 3840 or max(w, h) > 2 * min(w, h):
    raise SystemExit('Set emulator dimensions to 1080x1920 before store capture.')
args.output.parent.mkdir(parents=True, exist_ok=True)
screen.convert('RGB').save(args.output)
print(f'Captured actual screen: {args.output} ({w}x{h}, RGB PNG)')
