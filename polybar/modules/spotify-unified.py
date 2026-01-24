#!/usr/bin/env python3
# ~/.config/polybar/modules/spotify-unified.py

import subprocess
import sys
import os
import urllib.request
from io import BytesIO

try:
    import dbus
except ImportError:
    print("")
    sys.exit(0)

try:
    from colorthief import ColorThief
    import colorsys
    HAS_COLORTHIEF = True
except ImportError:
    HAS_COLORTHIEF = False

def get_spotify_interfaces():
    try:
        session_bus = dbus.SessionBus()
        spotify_bus = session_bus.get_object(
            'org.mpris.MediaPlayer2.spotify',
            '/org/mpris/MediaPlayer2'
        )
        player = dbus.Interface(spotify_bus, 'org.mpris.MediaPlayer2.Player')
        properties = dbus.Interface(spotify_bus, 'org.freedesktop.DBus.Properties')
        return player, properties
    except:
        return None, None

def get_playback_status(properties):
    if not properties:
        return None
    try:
        return properties.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus')
    except:
        return None

def get_metadata(properties):
    if not properties:
        return None
    try:
        return properties.Get('org.mpris.MediaPlayer2.Player', 'Metadata')
    except:
        return None

def get_dominant_color(image_url):
    """Pega a cor dominante da capa do álbum"""
    if not HAS_COLORTHIEF:
        return None
    
    try:
        with urllib.request.urlopen(image_url, timeout=2) as response:
            img_data = response.read()
        
        color_thief = ColorThief(BytesIO(img_data))
        palette = color_thief.get_palette(color_count=5, quality=1)
        
        # Procura pela cor mais saturada e vibrante
        best_color = None
        max_saturation = 0
        
        for r, g, b in palette:
            h, s, v = colorsys.rgb_to_hsv(r/255.0, g/255.0, b/255.0)
            # Prefere cores saturadas e não muito escuras/claras
            if s > 0.2 and 0.2 < v < 0.9:
                if s > max_saturation:
                    max_saturation = s
                    best_color = (r, g, b)
        
        if best_color is None:
            best_color = color_thief.get_color(quality=1)
        
        # Aumenta saturação e ajusta brilho para ficar mais vibrante
        r, g, b = best_color
        h, s, v = colorsys.rgb_to_hsv(r/255.0, g/255.0, b/255.0)
        s = min(1.0, s * 1.5)  # Aumenta saturação
        v = max(0.5, min(0.85, v))  # Ajusta brilho
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        
        return f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"
    except:
        return None

def truncate_text(text, max_length=45):
    """Trunca texto longo"""
    if len(text) > max_length:
        return text[:max_length-3] + "..."
    return text

def handle_action(action, player):
    if not player:
        return
    try:
        if action == 'previous':
            player.Previous()
        elif action == 'next':
            player.Next()
        elif action == 'playpause':
            player.PlayPause()
    except:
        pass

def main():
    # Handle actions
    if len(sys.argv) > 1:
        action = sys.argv[1]
        player, properties = get_spotify_interfaces()
        handle_action(action, player)
        return

    try:
        player, properties = get_spotify_interfaces()
        
        if not properties:
            print("")
            return

        status = get_playback_status(properties)
        
        if not status:
            print("")
            return

        metadata = get_metadata(properties)
        script_path = os.path.abspath(__file__)
        
        # Pega a cor do álbum se estiver tocando
        color = None
        if status == 'Playing' and metadata and HAS_COLORTHIEF:
            art_url = metadata.get('mpris:artUrl', '')
            if art_url:
                color = get_dominant_color(art_url)
        
        # Ícone do Spotify
        if color:
            # Usa a cor da música no ícone
            spotify_icon = f"%{{F{color}}}󰓇%{{F-}}"
        else:
            # Verde padrão do Spotify
            spotify_icon = "%{F#1DB954}󰓇%{F-}"
        
        # Controles
        prev_btn = f"%{{A1:python3 {script_path} previous:}}󰒮%{{A}}"
        
        if status == 'Playing':
            play_btn = f"%{{A1:python3 {script_path} playpause:}}󰏤%{{A}}"
        else:
            play_btn = f"%{{A1:python3 {script_path} playpause:}}󰐊%{{A}}"
        
        next_btn = f"%{{A1:python3 {script_path} next:}}󰒬%{{A}}"
        
        controls = f"{prev_btn} {play_btn} {next_btn}"
        
        # Monta o output
        parts = [spotify_icon, controls]
        
        # Info da música (se tocando)
        if status == 'Playing' and metadata:
            artist = metadata.get('xesam:artist', [''])[0] if metadata.get('xesam:artist') else ''
            song = metadata.get('xesam:title', '')
            
            if artist and song:
                text = truncate_text(f" {artist} - {song}", 45)
                parts.append(text)
        
        output = " ".join(parts)
        
        # Adiciona overline colorido (barra em cima) se tiver cor
        if color and status == 'Playing':
            output = f"%{{o{color}}}%{{+o}}{output}%{{-o}}"
        
        print(output)
        
    except:
        print("")

if __name__ == '__main__':
    main()