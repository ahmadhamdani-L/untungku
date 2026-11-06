"""Compose the Play feature graphic from the original brand and real app capture."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
ROOT=Path(__file__).resolve().parents[1]
S=3
W,H=1024,500
im=Image.new('RGB',(W*S,H*S))
pixels=im.load()
for y in range(H*S):
 for x in range(W*S):
  t=(x/(W*S)*.7+y/(H*S)*.3)
  a,b=(10,27,31),(5,88,63)
  pixels[x,y]=tuple(int(a[k]+(b[k]-a[k])*t) for k in range(3))
d=ImageDraw.Draw(im)
def box(rect,fill,radius=0,outline=None,width=1):
 d.rounded_rectangle(tuple(int(v*S) for v in rect),radius=int(radius*S),fill=fill,outline=outline,width=width*S)
def font(size,bold=False):
 return ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial'+(' Bold' if bold else '')+'.ttf',int(size*S))
def text(x,y,value,size,color='white',bold=False):
 d.text((x*S,y*S),value,font=font(size,bold),fill=color)
# Quiet geometric texture, with the important content kept inside the central safe area.
d.ellipse((590*S,-175*S,1140*S,375*S),fill='#0B624D')
d.ellipse((760*S,190*S,1190*S,620*S),fill='#087D59')
icon=Image.open(ROOT/'assets/branding/untungku-icon-512.png').convert('RGB').resize((48*S,48*S),Image.Resampling.LANCZOS)
mask=Image.new('L',icon.size);ImageDraw.Draw(mask).rounded_rectangle((0,0,48*S,48*S),radius=13*S,fill=255)
im.paste(icon,(62*S,52*S),mask)
text(124,59,'UntungKu Pro',27,bold=True)
text(62,141,'Usaha rapi.',58,bold=True)
text(62,208,'Untung terpantau.',54,'#D9FF85',True)
text(65,294,'Penjualan, stok & piutang',23,'#D9EAE4')
text(65,327,'dalam satu aplikasi.',23,'#D9EAE4')
for x,label,width in [(64,'Offline',90),(166,'Tanpa akun',134),(312,'Untuk UMKM',151)]:
 box((x,399,x+width,435),'#17483D',18,outline='#3B6C5D')
 text(x+16,409,label,15,'#DCF1E5',True)
# A real screenshot, presented in a simple device frame; no fabricated UI.
screen=Image.open(ROOT/'docs/store-screenshots/01-dashboard.png').convert('RGB')
phone_w,phone_h=214,380
phone_x,phone_y=730,59
shadow=Image.new('RGBA',im.size)
ImageDraw.Draw(shadow).rounded_rectangle(((phone_x-10)*S,(phone_y-7)*S,(phone_x+phone_w+16)*S,(phone_y+phone_h+18)*S),radius=34*S,fill=(0,0,0,110))
im=Image.alpha_composite(im.convert('RGBA'),shadow.filter(ImageFilter.GaussianBlur(12*S))).convert('RGB')
d=ImageDraw.Draw(im)
box((phone_x-9,phone_y-9,phone_x+phone_w+9,phone_y+phone_h+9),'#0A1718',31,outline='#63887A',width=1)
screen=screen.resize((phone_w*S,phone_h*S),Image.Resampling.LANCZOS)
mask=Image.new('L',screen.size);ImageDraw.Draw(mask).rounded_rectangle((0,0,screen.width,screen.height),radius=24*S,fill=255)
im.paste(screen,(phone_x*S,phone_y*S),mask)
# Small original brand accent, clear of the screenshot content.
box((678,355,778,422),'#D9FF85',18)
for x,y,h in [(700,390,13),(719,380,23),(738,369,34)]:box((x,y,x+11,y+h),'#07583F',3)
im.resize((W,H),Image.Resampling.LANCZOS).save(ROOT/'assets/branding/feature-graphic-1024x500.png')
print('Created feature graphic: 1024x500 RGB PNG')
