import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_haqdaar_logo(size=512, bg_transparent=True):
    # Create image with RGBA
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0) if bg_transparent else (19, 93, 56, 255))
    draw = ImageDraw.Draw(img)
    
    center = size / 2
    scale = size / 512.0
    
    # Primary colors
    forest_green = (19, 93, 56, 255)       # #135D38
    deep_green = (13, 64, 38, 255)         # #0D4026
    gold = (212, 175, 55, 255)             # #D4AF37
    bright_gold = (245, 215, 110, 255)     # #F5D76E
    cream = (248, 249, 250, 255)           # #F8F9FA
    white = (255, 255, 255, 255)
    
    # 1. Outer circle / shield background if transparent
    if bg_transparent:
        # Draw elegant circular badge with gradient-like double ring
        r = 230 * scale
        draw.ellipse([center - r, center - r, center + r, center + r], fill=forest_green)
        
        # Golden inner ring
        r_inner = 216 * scale
        draw.ellipse([center - r_inner, center - r_inner, center + r_inner, center + r_inner], outline=gold, width=int(5 * scale))
        
        # Subtle dotted / star accents in the ring or inner border
        r_inner2 = 206 * scale
        draw.ellipse([center - r_inner2, center - r_inner2, center + r_inner2, center + r_inner2], outline=deep_green, width=int(2 * scale))

    # 2. Draw Scales of Justice (Meezan / ترازو)
    # Central pillar
    pillar_top_y = 110 * scale
    pillar_bottom_y = 350 * scale
    pillar_width = int(14 * scale)
    
    # Pillar finial (decorative top)
    finial_r = 16 * scale
    draw.ellipse([center - finial_r, pillar_top_y - finial_r, center + finial_r, pillar_top_y + finial_r], fill=gold)
    
    # Pillar body (gradient gold)
    draw.rounded_rectangle([center - pillar_width/2, pillar_top_y, center + pillar_width/2, pillar_bottom_y], radius=int(6*scale), fill=bright_gold)
    
    # Central horizontal balance beam
    beam_y = 160 * scale
    beam_half_width = 145 * scale
    beam_thickness = int(10 * scale)
    draw.rounded_rectangle([center - beam_half_width, beam_y - beam_thickness/2, center + beam_half_width, beam_y + beam_thickness/2], radius=int(4*scale), fill=gold)
    
    # Beam center jewel / pivot
    pivot_r = 14 * scale
    draw.ellipse([center - pivot_r, beam_y - pivot_r, center + pivot_r, beam_y + pivot_r], fill=white, outline=gold, width=int(3*scale))
    
    # Left & Right Scale Pans (Cords + Pans)
    left_x = center - beam_half_width + 12 * scale
    right_x = center + beam_half_width - 12 * scale
    pan_y = 250 * scale
    cord_width = max(1, int(3 * scale))
    
    # Left pan cords
    draw.line([left_x, beam_y, left_x - 36 * scale, pan_y], fill=bright_gold, width=cord_width)
    draw.line([left_x, beam_y, left_x + 36 * scale, pan_y], fill=bright_gold, width=cord_width)
    
    # Left pan bowl (arc)
    pan_w = 42 * scale
    draw.pieslice([left_x - pan_w, pan_y - 12 * scale, left_x + pan_w, pan_y + 36 * scale], 0, 180, fill=bright_gold, outline=gold)
    
    # Right pan cords
    draw.line([right_x, beam_y, right_x - 36 * scale, pan_y], fill=bright_gold, width=cord_width)
    draw.line([right_x, beam_y, right_x + 36 * scale, pan_y], fill=bright_gold, width=cord_width)
    
    # Right pan bowl (arc)
    draw.pieslice([right_x - pan_w, pan_y - 12 * scale, right_x + pan_w, pan_y + 36 * scale], 0, 180, fill=bright_gold, outline=gold)
    
    # Pillar base (pedestal / stepped base representing the Constitution / Law Book)
    base_w1 = 120 * scale
    base_h1 = 16 * scale
    draw.rounded_rectangle([center - base_w1/2, pillar_bottom_y, center + base_w1/2, pillar_bottom_y + base_h1], radius=int(4*scale), fill=gold)
    
    base_w2 = 160 * scale
    base_h2 = 18 * scale
    draw.rounded_rectangle([center - base_w2/2, pillar_bottom_y + base_h1 + 2*scale, center + base_w2/2, pillar_bottom_y + base_h1 + base_h2 + 2*scale], radius=int(5*scale), fill=bright_gold)
    
    # Crescent & Star subtle emblem above the pillar finial
    # Draw small star
    star_cy = pillar_top_y - 28 * scale
    star_r = 10 * scale
    star_points = []
    for i in range(10):
        angle = i * (math.pi / 5) - math.pi / 2
        r_p = star_r if i % 2 == 0 else star_r * 0.45
        star_points.append((center + r_p * math.cos(angle), star_cy + r_p * math.sin(angle)))
    draw.polygon(star_points, fill=gold)

    # 3. Text "HaqDaar" banner at bottom
    # Elegant curved ribbon or crisp typography
    try:
        font = ImageFont.truetype("arial.ttf", int(36 * scale))
        text = "HAQDAAR"
        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        text_y = pillar_bottom_y + base_h1 + base_h2 + 10 * scale
        draw.text((center - tw/2, text_y), text, fill=white, font=font)
    except Exception:
        pass
        
    return img

os.makedirs("assets/images", exist_ok=True)

# Generate high-res main logo
logo_512 = create_haqdaar_logo(512, bg_transparent=True)
logo_512.save("assets/images/haqdaar_logo.png", "PNG")

# Generate solid background version for launcher / splash
logo_solid = create_haqdaar_logo(512, bg_transparent=False)
logo_solid.save("assets/images/haqdaar_icon_solid.png", "PNG")

# Update android mipmap launcher icons with this crisp logo
mipmap_sizes = {
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": 48,
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": 72,
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": 96,
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": 144,
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": 192,
}

for path, sz in mipmap_sizes.items():
    if os.path.exists(os.path.dirname(path)):
        scaled = create_haqdaar_logo(sz, bg_transparent=False)
        scaled.save(path, "PNG")

print("Logo generation complete!")
