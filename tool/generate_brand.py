"""Original geometric growth mark. Rebuild using Python 3 + Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw
root=Path(__file__).resolve().parents[1]
def icon(size):
 scale=4;s=size*scale
 im=Image.new('RGB',(s,s),'#087F5B');d=ImageDraw.Draw(im)
 # Three ascending columns and an ascending profit trajectory.
 for x,y in [(0.24,0.57),(0.43,0.43),(0.62,0.28)]:
  d.rounded_rectangle((int(x*s),int(y*s),int((x+.13)*s),int(.77*s)),radius=int(.035*s),fill='#D9FF85')
 d.line([(int(.24*s),int(.43*s)),(int(.46*s),int(.28*s)),(int(.69*s),int(.19*s))],fill='white',width=max(2,int(.035*s)))
 return im.resize((size,size),Image.Resampling.LANCZOS)
for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
 icon(size).save(root/f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
icon(512).convert('RGBA').save(root/'assets/branding/untungku-icon-512.png')
res=root/'android/app/src/main/res';(res/'mipmap-anydpi-v26').mkdir(exist_ok=True)
(res/'drawable/ic_launcher_foreground.xml').write_text('''<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108"><path android:fillColor="#D9FF85" android:pathData="M30,57 L42,57 L42,78 L30,78 Z M48,45 L60,45 L60,78 L48,78 Z M66,31 L78,31 L78,78 L66,78 Z"/><path android:strokeColor="#FFFFFF" android:strokeWidth="3" android:pathData="M30,45 L51,31 L75,22"/></vector>''')
(res/'values/colors.xml').write_text('<resources><color name="brand_green">#087F5B</color></resources>')
(res/'mipmap-anydpi-v26/ic_launcher.xml').write_text('''<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@color/brand_green"/><foreground android:drawable="@drawable/ic_launcher_foreground"/></adaptive-icon>''')
for name in ['drawable/launch_background.xml','drawable-v21/launch_background.xml']:
 (res/name).write_text('''<layer-list xmlns:android="http://schemas.android.com/apk/res/android"><item android:drawable="@color/brand_green"/><item android:gravity="center" android:drawable="@drawable/ic_launcher_foreground"/></layer-list>''')
from PIL import ImageFont
canvas=Image.new('RGB',(1024,500),'#07583F');draw=ImageDraw.Draw(canvas)
for x,y,r in [(930,60,170),(880,460,200)]:
 draw.ellipse((x-r,y-r,x+r,y+r),fill='#0B6549')
canvas.paste(icon(160),(64,70))
font='/System/Library/Fonts/Supplemental/Arial Bold.ttf'
regular='/System/Library/Fonts/Supplemental/Arial.ttf'
if Path(font).exists():
 draw.text((252,100),'UntungKu Pro',font=ImageFont.truetype(font,64),fill='white')
 draw.text((68,290),'Kelola usaha. Kenali untung.',font=ImageFont.truetype(font,48),fill='#D9FF85')
 draw.text((70,368),'Produk • Stok • Penjualan • Laba',font=ImageFont.truetype(regular,30),fill='#D0EADF')
canvas.save(root/'assets/branding/feature-graphic-1024x500.png')
