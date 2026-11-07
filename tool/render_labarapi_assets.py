"""Render repository-native SVG branding through Chrome, without generating UI.
Screenshots remain lossless captures of the running app; do not fabricate UI.
"""
from pathlib import Path
import subprocess, tempfile, argparse, base64, re
root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--feature',action='store_true')
args=parser.parse_args()
chrome='/Applications/work/Google Chrome.app/Contents/MacOS/Google Chrome'
def render(svg, output, width, height, alpha=False):
 with tempfile.TemporaryDirectory(prefix='labarapi-vector-') as temp:
  page=Path(temp)/'asset.html'
  page.write_text('<!doctype html><style>html,body{margin:0;padding:0;overflow:hidden;background:white}svg{display:block}</style>'+svg)
  if alpha:
   payload=base64.b64encode(svg.encode()).decode()
   page.write_text(f'<canvas id="c" width="{width}" height="{height}"></canvas><pre id="result"></pre><script>let im=new Image;im.onload=()=>{{c.getContext("2d").drawImage(im,0,0,{width},{height});result.textContent=c.toDataURL("image/png").split(",")[1]}};im.src="data:image/svg+xml;base64,{payload}"</script>')
   html=subprocess.check_output([chrome,'--headless','--disable-gpu','--no-sandbox',
      '--user-data-dir='+str(Path(temp)/'chrome'),'--virtual-time-budget=2000',
      '--dump-dom',page.as_uri()],stderr=subprocess.DEVNULL,text=True)
   encoded=re.search(r'<pre id="result">([A-Za-z0-9+/=]+)</pre>',html)
   if not encoded: raise RuntimeError('Vector PNG encoding failed')
   output.write_bytes(base64.b64decode(encoded[1]));return
  subprocess.run([chrome,'--headless','--disable-gpu','--no-sandbox','--hide-scrollbars',
    '--no-first-run','--user-data-dir='+str(Path(temp)/'chrome'),
    '--force-device-scale-factor=1','--window-size='+str(width)+','+str(height),
    '--screenshot='+str(output.resolve()),page.as_uri()],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
svg=(root/'assets/branding/labarapi/icon.svg').read_text()
render(svg,root/'assets/branding/untungku-icon-512.png',512,512,alpha=True)
for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
 render(svg.replace('width="512" height="512"',f'width="{size}" height="{size}"'),root/f'android/app/src/main/res/mipmap-{density}/ic_launcher.png',size,size,alpha=True)
if args.feature:
 shot=root/'build/labarapi-play-release/screenshots/01-dashboard.png'
 data=base64.b64encode(shot.read_bytes()).decode()
 feature=f'''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="500" viewBox="0 0 1024 500">
 <defs><linearGradient id="bg" x2="1" y2="1"><stop stop-color="#061B4D"/><stop offset="1" stop-color="#005CDD"/></linearGradient><clipPath id="screen"><rect x="748" y="41" width="230" height="410" rx="22"/></clipPath></defs>
 <rect width="1024" height="500" fill="url(#bg)"/><circle cx="1010" cy="80" r="240" fill="#268AFF" opacity=".25"/>
 <g font-family="Arial,sans-serif" fill="white"><text x="56" y="87" font-size="32" font-weight="700">LabaRapi</text>
 <text x="56" y="177" font-size="54" font-weight="700">Bikin usaha lebih rapi.</text>
 <text x="56" y="242" font-size="54" font-weight="700" fill="#A7DCFF">Laba lebih pasti.</text>
 <text x="58" y="307" font-size="24">Penjualan · Stok · Kas · Piutang</text>
 <text x="58" y="345" font-size="24">Laporan usaha dalam satu aplikasi.</text>
 <rect x="56" y="392" width="346" height="45" rx="22" fill="#0078F0"/><text x="78" y="422" font-size="20" font-weight="700">Untuk UMKM · Bisa offline</text></g>
 <rect x="739" y="32" width="248" height="428" rx="31" fill="#D9EAFF"/>
 <image href="data:image/png;base64,{data}" x="748" y="41" width="230" height="410" clip-path="url(#screen)" preserveAspectRatio="none"/>
 </svg>'''
 (root/'assets/branding/labarapi/feature.svg').write_text(feature)
 render(feature,root/'assets/branding/feature-graphic-1024x500.png',1024,500)
print('LabaRapi vector assets rendered')
