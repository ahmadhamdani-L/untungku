"""Render original vector motion graphics + real app captures into two MP4 ads.

Requires macOS sips (SVG rendering), ffmpeg/libx264 and Python stdlib.
No stock footage, third-party music, network requests, or production ad requests.
"""
import argparse
import array
import base64
import html
import json
import math
from pathlib import Path
import shutil
import subprocess
import wave

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--output-dir', type=Path, default=ROOT / 'build/promo')
args = parser.parse_args()
out = args.output_dir.resolve()
out.mkdir(parents=True, exist_ok=True)
for executable in ['ffmpeg', 'ffprobe', 'sips']:
    if not shutil.which(executable):
        raise SystemExit('Missing tool: ' + executable)

SCENES = [
    ('USAHA ANDA, LEBIH TERATUR', ['Usaha rapi.', 'Untung lebih pasti.'],
     ['Catat kegiatan usaha.', 'Lihat ringkasannya dalam satu aplikasi.'], '01-dashboard.png'),
    ('PRODUK & STOK', ['Produk tertata.', 'Stok terpantau.'],
     ['Kelola harga, modal, dan kategori.', 'Pantau stok dari perangkat Anda.'], '02-products.png'),
    ('PENJUALAN & PENGELUARAN', ['Catatan rapi.', 'Usaha terkendali.'],
     ['Catat penjualan banyak produk.', 'Kelola pengeluaran usaha.'], '03-transactions.png'),
    ('KALKULATOR LABA', ['Hitung harga.', 'Pahami laba.'],
     ['Simulasikan margin dan target laba.', 'Hasil mengikuti data yang Anda isi.'], '05-calculator-results.png'),
    ('SIAP DIGUNAKAN OFFLINE', ['Tetap jalan,', 'meski offline.'],
     ['Tanpa akun untuk mencatat usaha.', 'Simpan backup JSON dan ekspor CSV.'], '07-dashboard-dark.png'),
    ('UNTUK PEMILIK UMKM', ['UntungKu Pro', 'untuk usaha Anda.'],
     ['Segera hadir di Google Play.', 'Pencatatan usaha dalam Bahasa Indonesia.'], '01-dashboard.png'),
]
logo = base64.b64encode((ROOT / 'assets/branding/untungku-icon-512.png').read_bytes()).decode()

def text(x, y, lines, size, color='#ECF8EF', weight=400, leading=None):
    leading = leading or size * 1.24
    return ''.join(f'<text x="{x}" y="{y+i*leading}" font-family="Arial,Helvetica,sans-serif" font-size="{size}" font-weight="{weight}" fill="{color}">{html.escape(line)}</text>' for i, line in enumerate(lines))

def background(index, vertical):
    tag, headline, subtitle, _ = SCENES[index]
    w, h = (1080, 1920) if vertical else (1920, 1080)
    x = 72 if vertical else 92
    y = 64 if vertical else 70
    brand_x = x + 96
    title_y = 280 if vertical else 360
    title_size = 68 if vertical else 84
    sub_y = 460 if vertical else 620
    sub_size = 30 if vertical else 34
    px, py, pw, ph = (216, 590, 648, 1152) if vertical else (1280, 90, 506, 900)
    progress_y = 1870 if vertical else 1015
    bar_w = 142 if vertical else 140
    footer = 'Simulasi kalkulator, bukan jaminan laba.' if index == 3 else ('Segera hadir di Google Play' if index == 5 else 'UntungKu Pro  /  Pencatatan usaha offline')
    s = f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#071E17"/><stop offset="1" stop-color="#103F2F"/></linearGradient></defs>
<rect width="{w}" height="{h}" fill="url(#bg)"/>
<circle cx="{w+70}" cy="{h//2}" r="{w//2}" fill="#12805D" opacity=".10"/>
<circle cx="{w-160}" cy="{h-60}" r="310" fill="none" stroke="#C4F45B" stroke-width="2" opacity=".12"/>
<image x="{x}" y="{y}" width="72" height="72" xlink:href="data:image/png;base64,{logo}"/>
'''
    s += text(brand_x, y+49, ['UntungKu Pro'], 36, weight=700)
    s += text(x, 195 if vertical else 235, [tag], 23, '#C4F45B', 700)
    s += text(x, title_y, headline, title_size, weight=700, leading=title_size*1.17)
    s += text(x, sub_y, subtitle, sub_size, '#BBD4C6', leading=46)
    s += f'<rect x="{px-14}" y="{py-14}" width="{pw+28}" height="{ph+28}" rx="30" fill="#375A48"/><rect x="{px-6}" y="{py-6}" width="{pw+12}" height="{ph+12}" rx="24" fill="#E7EFE9"/>'
    s += text(x, 1825 if vertical else 960, [footer], 23, '#BBD4C6')
    for j in range(6):
        color = '#C4F45B' if j <= index else '#375A48'
        s += f'<rect x="{x+j*(bar_w+12)}" y="{progress_y}" width="{bar_w}" height="5" rx="2" fill="{color}"/>'
    return s+'</svg>', (w, h, px, py, pw, ph)

# A soft original instrumental bed: six chords with a quiet plucked arpeggio.
sr = 22050
chords = [(220,261.63,329.63), (174.61,220,261.63), (130.81,164.81,196),
          (196,246.94,293.66), (220,261.63,329.63), (130.81,164.81,196)]
samples = array.array('h')
for n in range(sr*30):
    t = n/sr
    chord = chords[min(int(t//5),5)]
    local = t%5
    env = min(1,local/.6,(5-local)/.8)
    pad = sum(math.sin(2*math.pi*f*t) + .12*math.sin(4*math.pi*f*t) for f in chord)/3
    beat = local%1.25
    note = chord[int(local/1.25)%3]*2
    pluck = math.sin(2*math.pi*note*t)*math.exp(-beat*7)*min(1,beat/.015)
    fade = min(1,t/.8,(30-t)/1.3)
    value = (.11*env*pad+.055*pluck)*fade
    samples.append(int(max(-1,min(1,value))*32767))
with wave.open(str(out/'original-instrumental.wav'),'wb') as wav:
    wav.setnchannels(1); wav.setsampwidth(2); wav.setframerate(sr); wav.writeframes(samples.tobytes())

subtitle = []
for i, (_, headline, _, _) in enumerate(SCENES):
    subtitle.append(f'{i+1}\n00:00:{i*5:02d},000 --> 00:00:{(i+1)*5:02d},000\n'+ ' '.join(headline)+'\n')
(out/'untungku-promo-id.srt').write_text('\n'.join(subtitle))

for vertical in [False, True]:
    mode = 'vertical' if vertical else 'landscape'
    clips = []
    for index, scene in enumerate(SCENES):
        svg, (w,h,px,py,pw,ph) = background(index,vertical)
        stem = out/f'{mode}-{index+1:02d}'
        svg_path = stem.with_suffix('.svg'); png = stem.with_suffix('.png')
        svg_path.write_text(svg)
        subprocess.run(['sips','-s','format','png',str(svg_path),'--out',str(png)],capture_output=True,check=True)
        clip = stem.with_suffix('.mp4')
        graph = (f'[0:v]format=yuv420p[bg];[1:v]scale={pw}:{ph},format=yuv420p[screen];'
                 f'[bg][screen]overlay=x={px}:y=\'{py}+4*sin(PI*t/5)\':shortest=1,'
                 'fade=t=in:st=0:d=0.22,fade=t=out:st=4.78:d=0.22,setsar=1[v]')
        cmd = ['ffmpeg','-hide_banner','-loglevel','error','-y',
               '-loop','1','-framerate','30','-i',str(png),
               '-loop','1','-framerate','30','-i',str(ROOT/'docs/store-screenshots'/scene[3]),
               '-filter_complex',graph,'-map','[v]','-t','5','-an','-c:v','libx264',
               '-preset','veryfast','-crf','20','-pix_fmt','yuv420p','-threads','2',str(clip)]
        subprocess.run(cmd,check=True)
        clips.append(clip)
        print(f'Rendered {mode} scene {index+1}/6',flush=True)
    concat = out/f'{mode}-concat.txt'
    concat.write_text(''.join("file '"+str(p)+"'\n" for p in clips))
    final = out/f'UntungKu-Pro-Promo-30s-{mode}.mp4'
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','concat','-safe','0','-i',str(concat),
                    '-i',str(out/'original-instrumental.wav'),'-map','0:v:0','-map','1:a:0',
                    '-c:v','copy','-c:a','aac','-b:a','160k','-ar','48000','-ac','2',
                    '-af','loudnorm=I=-20:TP=-2:LRA=7','-t','30','-movflags','+faststart',str(final)],check=True)
    probe = json.loads(subprocess.run(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(final)],capture_output=True,text=True,check=True).stdout)
    (out/f'{mode}-verification.json').write_text(json.dumps(probe,indent=2)+'\n')
    print('Completed:',final.name,flush=True)
