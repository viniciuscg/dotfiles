#!/usr/bin/env python3

import subprocess
import sys
from spotify_common import get_spotify_interfaces, get_playback_status, get_metadata, is_spotify_running

def get_spotify_color():
    import os
    script_dir = os.path.dirname(os.path.abspath(__file__))
    color_script = os.path.join(script_dir, 'spotify-color.py')
    try:
        result = subprocess.run(
            ['python3', color_script],
            capture_output=True,
            text=True,
            timeout=3
        )
        color = result.stdout.strip()
        return color if color and color.startswith('#') else None
    except:
        return None

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
    except Exception:
        pass

def main():
    if len(sys.argv) > 1:
        action = sys.argv[1]
        player, properties = get_spotify_interfaces()
        handle_action(action, player)
        return
    
    try:
        player, properties = get_spotify_interfaces()
        
        if not is_spotify_running(properties):
            print("")
            return
        
        status = get_playback_status(properties)
        color = get_spotify_color()
        
        parts = []
        
        greenIcon = "󰓇"
        greenIcon = f"%{{F#6FB379}}{greenIcon}%{{F-}}"
        
        import os
        script_path = os.path.abspath(__file__)
        parts.append(f"%{{A1:python3 {script_path} previous:}}󰒮%{{A}}")
        
        if status == 'Playing':
            parts.append(f"%{{A1:python3 {script_path} playpause:}}󰏤%{{A}}")
        elif status == 'Paused':
            parts.append(f"%{{A1:python3 {script_path} playpause:}}󰐊%{{A}}")
        else:
            parts.append("󰐊")
        
        parts.append(f"%{{A1:python3 {script_path} next:}}󰒬%{{A}}")
        
        parts.append(greenIcon)
        if status == 'Playing':
            metadata = get_metadata(properties)
            if metadata:
                artist = metadata['xesam:artist'][0] if metadata['xesam:artist'] else ''
                song = metadata['xesam:title'] if metadata['xesam:title'] else ''
                parts.append(f"{artist}: {song}")
        
        content = "  ".join(parts)
        if color:
            print(f"%{{u{color}}}%{{+u}}{content}%{{-u}}")
        else:
            print(content)
            
    except Exception:
        print("")

if __name__ == '__main__':
    main()

