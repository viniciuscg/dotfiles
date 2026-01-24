#!/usr/bin/env python3

import urllib.request
from io import BytesIO
from colorthief import ColorThief
import colorsys

from spotify_common import get_spotify_interfaces, get_playback_status, get_metadata

def get_dominant_color(image_url):
    try:
        with urllib.request.urlopen(image_url, timeout=2) as response:
            img_data = response.read()
        
        color_thief = ColorThief(BytesIO(img_data))
        
        palette = color_thief.get_palette(color_count=5, quality=1)
        
        best_color = None
        max_saturation = 0
        
        for r, g, b in palette:
            h, s, v = colorsys.rgb_to_hsv(r/255.0, g/255.0, b/255.0)
            if s > 0.2 and 0.2 < v < 0.9:
                if s > max_saturation:
                    max_saturation = s
                    best_color = (r, g, b)
        
        if best_color is None:
            best_color = color_thief.get_color(quality=1)
        
        r, g, b = best_color
        
        h, s, v = colorsys.rgb_to_hsv(r/255.0, g/255.0, b/255.0)
        
        s = min(1.0, s * 1.8)
        
        v = max(0.6, min(0.9, v))
        
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        
        return f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"
    except Exception:
        return None

def main(): 
    try:
        player, properties = get_spotify_interfaces()
        if not properties:
            print("")
            return
        
        status = get_playback_status(properties)
        if status != 'Playing':
            print("")
            return
        
        metadata = get_metadata(properties)
        if not metadata:
            print("")
            return
        
        art_url = metadata.get('mpris:artUrl', '')
        if not art_url:
            print("")
            return
        
        color = get_dominant_color(art_url)
        if color:
            print(color)
        else:
            print("")
    except Exception:
        print("")

if __name__ == '__main__':
    main()
