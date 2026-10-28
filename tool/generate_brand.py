"""Generate LarisKas raster assets from an original, code-defined vector mark."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / 'android/app/src/main/res'
BLUE = '#165BE7'
NAVY = '#12366E'
LIGHT = '#EAF2FF'


def icon(size):
    scale = 4
    s = size * scale
    image = Image.new('RGB', (s, s), BLUE)
    draw = ImageDraw.Draw(image)
    # A shop awning and a white L-shaped ledger/counter.
    draw.rounded_rectangle((.17*s, .35*s, .83*s, .72*s), radius=.055*s, fill='white')
    draw.polygon([(.14*s,.38*s),(.24*s,.20*s),(.76*s,.20*s),(.86*s,.38*s)], fill=LIGHT)
    for x in (.29, .43, .57, .71):
        draw.line((x*s,.23*s,x*s,.38*s), fill=BLUE, width=max(2,int(.015*s)))
    draw.rounded_rectangle((.30*s,.44*s,.39*s,.66*s), radius=.012*s, fill=NAVY)
    draw.rounded_rectangle((.30*s,.59*s,.64*s,.66*s), radius=.012*s, fill=NAVY)
    draw.rounded_rectangle((.70*s,.47*s,.78*s,.64*s), radius=.012*s, fill=BLUE)
    return image.resize((size,size),Image.Resampling.LANCZOS)


for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    icon(size).save(RES/f'mipmap-{density}/ic_launcher.png')
icon(512).save(ROOT/'assets/branding/lariskas-icon-512.png')
(RES/'drawable/ic_launcher_foreground.xml').write_text('''<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108"><path android:fillColor="#EAF2FF" android:pathData="M23,42 L32,25 L76,25 L85,42 Z"/><path android:fillColor="#FFFFFF" android:pathData="M27,42 L81,42 Q84,42 84,45 L84,76 Q84,79 81,79 L27,79 Q24,79 24,76 L24,45 Q24,42 27,42 Z"/><path android:fillColor="#12366E" android:pathData="M35,49 L42,49 L42,70 L65,70 L65,76 L35,76 Z"/><path android:fillColor="#165BE7" android:pathData="M70,50 L78,50 L78,68 L70,68 Z"/><path android:strokeColor="#165BE7" android:strokeWidth="1.6" android:pathData="M37,27 L37,41 M49,27 L49,41 M61,27 L61,41 M73,27 L73,41"/></vector>''')
(RES/'values/colors.xml').write_text('<resources><color name="brand_blue">#165BE7</color></resources>')
(RES/'mipmap-anydpi-v26/ic_launcher.xml').write_text('''<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@color/brand_blue"/><foreground android:drawable="@drawable/ic_launcher_foreground"/></adaptive-icon>''')
for name in ['drawable/launch_background.xml','drawable-v21/launch_background.xml']:
    (RES/name).write_text('''<layer-list xmlns:android="http://schemas.android.com/apk/res/android"><item android:drawable="@color/brand_blue"/><item android:gravity="center" android:drawable="@drawable/ic_launcher_foreground"/></layer-list>''')
(RES/'values-v31/styles.xml').write_text('''<resources><style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar"><item name="android:windowSplashScreenBackground">@color/brand_blue</item><item name="android:windowSplashScreenAnimatedIcon">@drawable/ic_launcher_foreground</item><item name="android:windowLightStatusBar">false</item></style></resources>''')
canvas=Image.new('RGB',(1024,500),NAVY)
draw=ImageDraw.Draw(canvas)
for x,y,r in [(930,60,170),(880,460,200)]:
    draw.ellipse((x-r,y-r,x+r,y+r),fill=BLUE)
canvas.paste(icon(160),(64,70))
font='/System/Library/Fonts/Supplemental/Arial Bold.ttf'
regular='/System/Library/Fonts/Supplemental/Arial.ttf'
if Path(font).exists():
    draw.text((252,100),'LarisKas',font=ImageFont.truetype(font,68),fill='white')
    draw.text((68,290),'Usaha Rapi, Bisnis Makin Laris.',font=ImageFont.truetype(font,43),fill=LIGHT)
    draw.text((70,368),'Produk • Stok • Penjualan • Laba',font=ImageFont.truetype(regular,30),fill='white')
canvas.save(ROOT/'assets/branding/feature-graphic-1024x500.png')
