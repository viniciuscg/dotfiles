#!/usr/bin/env python3
import os
import sys
import subprocess
import json
from pathlib import Path

WALLPAPER_DIR = Path.home() / ".config" / "wallpaper"
STATE_FILE = Path.home() / ".config" / "polybar" / ".wallpaper_state"
SUPPORTED_FORMATS = {'.jpg', '.jpeg', '.png', '.webp'}

def get_wallpapers():
    """Get all wallpapers from directory, sorted by number if they have numbers in filename"""
    wallpapers = []
    if not WALLPAPER_DIR.exists():
        return wallpapers
    
    import re
    
    for file in sorted(WALLPAPER_DIR.iterdir()):
        if file.suffix.lower() in SUPPORTED_FORMATS:
            # Try to extract number from filename
            name = file.stem
            number = None
            try:
                # Try to find number in filename (e.g., "1.jpg", "wallpaper_2.jpg", "39kprhjkreag1")
                # Look for numbers at the start or end of filename
                match_start = re.match(r'^(\d+)', name)
                match_end = re.search(r'(\d+)$', name)
                
                if match_start:
                    number = int(match_start.group(1))
                elif match_end:
                    number = int(match_end.group(1))
                else:
                    # If no number found, use index based on alphabetical order
                    number = 9999 + len(wallpapers)  # Put unnumbered files at the end
            except:
                number = 9999 + len(wallpapers)
            
            wallpapers.append({
                'path': str(file),
                'name': file.name,
                'number': number
            })
    
    # Sort by number, then by name
    wallpapers.sort(key=lambda x: (x['number'], x['name']))
    
    # Reassign sequential numbers for display
    for i, wp in enumerate(wallpapers):
        wp['display_number'] = i + 1
    return wallpapers

def get_current_index():
    """Get current wallpaper index from state file"""
    if STATE_FILE.exists():
        try:
            with open(STATE_FILE, 'r') as f:
                state = json.load(f)
                return state.get('index', 0)
        except:
            pass
    return 0

def save_state(index, wallpaper_path):
    """Save current wallpaper state"""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STATE_FILE, 'w') as f:
        json.dump({'index': index, 'path': wallpaper_path}, f)

def set_wallpaper(wallpaper_path):
    """Set wallpaper using feh"""
    subprocess.run(['feh', '--bg-scale', wallpaper_path], 
                   stdout=subprocess.DEVNULL, 
                   stderr=subprocess.DEVNULL)

def main():
    wallpapers = get_wallpapers()
    
    if not wallpapers:
        print(" No wallpapers")
        return
    
    current_index = get_current_index()
    
    # Handle click/scroll events
    if len(sys.argv) > 1:
        action = sys.argv[1]
        
        if action == 'next':
            # Click left - next wallpaper
            current_index = (current_index + 1) % len(wallpapers)
            wallpaper = wallpapers[current_index]
            set_wallpaper(wallpaper['path'])
            save_state(current_index, wallpaper['path'])
            print(f" {current_index + 1}/{len(wallpapers)}")
            
        elif action == 'prev':
            # Click right - previous wallpaper
            current_index = (current_index - 1) % len(wallpapers)
            wallpaper = wallpapers[current_index]
            set_wallpaper(wallpaper['path'])
            save_state(current_index, wallpaper['path'])
            print(f" {current_index + 1}/{len(wallpapers)}")
            
        elif action.startswith('set:'):
            # Set specific wallpaper by number (scroll or direct selection)
            try:
                target_num = int(action.split(':')[1])
                # Find wallpaper with this number or index
                found = False
                for i, wp in enumerate(wallpapers):
                    if wp['number'] == target_num or i == target_num - 1:
                        set_wallpaper(wp['path'])
                        save_state(i, wp['path'])
                        print(f" {i + 1}/{len(wallpapers)}")
                        found = True
                        break
                if not found:
                    print(f" {current_index + 1}/{len(wallpapers)}")
            except:
                print(f" {current_index + 1}/{len(wallpapers)}")
                
        elif action == 'scroll-up':
            # Scroll up - next
            current_index = (current_index + 1) % len(wallpapers)
            wallpaper = wallpapers[current_index]
            set_wallpaper(wallpaper['path'])
            save_state(current_index, wallpaper['path'])
            print(f" {current_index + 1}/{len(wallpapers)}")
            
        elif action == 'scroll-down':
            # Scroll down - previous
            current_index = (current_index - 1) % len(wallpapers)
            wallpaper = wallpapers[current_index]
            set_wallpaper(wallpaper['path'])
            save_state(current_index, wallpaper['path'])
            print(f" {current_index + 1}/{len(wallpapers)}")
            
        elif action == 'select':
            # Show menu to select specific wallpaper
            try:
                # Try rofi first, then dmenu
                menu_items = []
                for i, wp in enumerate(wallpapers):
                    marker = "✓ " if i == current_index else "  "
                    menu_items.append(f"{marker}{i+1}. {wp['name']}")
                
                menu_text = "\n".join(menu_items)
                
                # Try rofi
                try:
                    result = subprocess.run(
                        ['rofi', '-dmenu', '-p', 'Select Wallpaper:', '-i'],
                        input=menu_text,
                        text=True,
                        capture_output=True,
                        timeout=5
                    )
                    if result.returncode == 0 and result.stdout.strip():
                        selected = result.stdout.strip()
                        # Extract number from selection
                        import re
                        match = re.search(r'(\d+)', selected)
                        if match:
                            target_num = int(match.group(1))
                            if 1 <= target_num <= len(wallpapers):
                                target_index = target_num - 1
                                wallpaper = wallpapers[target_index]
                                set_wallpaper(wallpaper['path'])
                                save_state(target_index, wallpaper['path'])
                                print(f" {target_index + 1}/{len(wallpapers)}")
                                return
                except:
                    pass
                
                # Fallback to dmenu
                try:
                    result = subprocess.run(
                        ['dmenu', '-l', str(len(wallpapers)), '-p', 'Select Wallpaper:'],
                        input=menu_text,
                        text=True,
                        capture_output=True,
                        timeout=5
                    )
                    if result.returncode == 0 and result.stdout.strip():
                        selected = result.stdout.strip()
                        import re
                        match = re.search(r'(\d+)', selected)
                        if match:
                            target_num = int(match.group(1))
                            if 1 <= target_num <= len(wallpapers):
                                target_index = target_num - 1
                                wallpaper = wallpapers[target_index]
                                set_wallpaper(wallpaper['path'])
                                save_state(target_index, wallpaper['path'])
                                print(f" {target_index + 1}/{len(wallpapers)}")
                                return
                except:
                    pass
                
                # If menu fails, just show current
                print(f" {current_index + 1}/{len(wallpapers)}")
            except:
                print(f" {current_index + 1}/{len(wallpapers)}")
    else:
        # Just display current wallpaper info
        # If state file doesn't exist, save the first wallpaper as default
        if not STATE_FILE.exists() and wallpapers:
            wallpaper = wallpapers[0]
            set_wallpaper(wallpaper['path'])
            save_state(0, wallpaper['path'])
        
        wallpaper = wallpapers[current_index]
        print(f" {current_index + 1}/{len(wallpapers)}")

if __name__ == '__main__':
    main()
