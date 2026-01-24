#!/usr/bin/env python3
# ~/.config/polybar/modules/audio-unified-minimal.py

import subprocess
import sys
import re

SINKS = [
    "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_3__sink",
    "alsa_output.usb-Corsair_CORSAIR_HS55_Wireless_Gaming_Receiver_79A71566FBCB0AC1-00.analog-stereo",
]

ICON_SPEAKERS = "󰕾"
ICON_HEADPHONES = "󰋋"
ICON_MUTED = "󰝟"

def pactl(cmd, ignore_errors=False):
    try:
        result = subprocess.run(
            ["pactl"] + cmd.split(),
            capture_output=True,
            text=True,
            timeout=2,
            check=False
        )
        if result.returncode == 0:
            return result.stdout.strip()
        elif ignore_errors:
            return ""
        else:
            return "" if result.stderr else ""
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError, ValueError):
        return ""

def notify(title, message, value=None):
    """Send notification with optional progress bar"""
    cmd = f'notify-send -a "volume" -t 2000 "{title}" "{message}"'
    if value is not None:
        cmd = f'notify-send -a "volume" -h string:x-canonical-private-synchronous:volume -h int:value:{value} -t 2000 "{title}" "{message}"'
    subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def get_default_sink():
    return pactl("get-default-sink")

def get_current_sink():
    out = pactl("list sink-inputs")
    if out:
        blocks = out.split("Sink Input #")[1:]
        for block in blocks:
            match = re.search(r"Sink:\s+(\S+)", block)
            if match:
                return match.group(1)
    return get_default_sink()

def get_active_sink():
    return get_current_sink()

def change_sink():
    try:
        current_sink = get_default_sink()
        if not current_sink:
            return
        
        next_sink = SINKS[0] if current_sink == SINKS[1] else SINKS[1]
        pactl(f"set-default-sink {next_sink}")
        
        # Move all active streams
        streams = pactl("list short sink-inputs")
        if streams:
            for line in streams.splitlines():
                if not line.strip():
                    continue
                parts = line.split("\t")
                if len(parts) > 0 and parts[0].isdigit():
                    stream_id = parts[0]
                    pactl(f"move-sink-input {stream_id} {next_sink}")
        
        device_name = get_device_name(next_sink)
        notify("Áudio", f"Dispositivo alterado: {device_name}")
    except Exception:
        pass

def set_volume(delta):
    sink = get_active_sink()
    sign = "+" if delta > 0 else ""
    pactl(f"set-sink-volume {sink} {sign}{delta}%")
    vol = get_volume()
    notify("Volume", f"{vol}%", vol)

def toggle_mute():
    try:
        sink = get_active_sink()
        if sink:
            pactl(f"set-sink-mute {sink} toggle")
            if is_muted():
                notify("Volume", "Mudo 🔇")
            else:
                vol = get_volume()
                notify("Volume", f"Som ativado 🔊 {vol}%")
    except Exception:
        pass

def get_volume():
    sink = get_current_sink()
    out = pactl(f"get-sink-volume {sink}")
    m = re.search(r"(\d+)%", out)
    return int(m.group(1)) if m else 0

def is_muted():
    return "yes" in pactl("get-sink-mute @DEFAULT_SINK@").lower()

def sink_icon(sink):
    if "usb" in sink.lower() or "corsair" in sink.lower():
        return ICON_HEADPHONES
    return ICON_SPEAKERS

def get_device_name(sink):
    if not sink:
        return "Unknown"
    
    if "usb" in sink.lower() or "corsair" in sink.lower() or "headphone" in sink.lower():
        return "Headphones"
    
    if "pci" in sink.lower() or "sofhdadsp" in sink.lower() or "platform" in sink.lower():
        return "Speakers"
    
    name = sink.replace("alsa_output.", "").split(".")[0]
    name = name.replace("_", " ").replace("-", " ")
    if len(name) > 15:
        name = name[:12] + "..."
    return name if name else "Audio"

def display_audio():
    """Display only device icon (minimal)"""
    try:
        sink = get_default_sink()
        if not sink:
            print(f"{ICON_MUTED}")
            return
        
        icon = sink_icon(sink)
        print(f"{icon}")
    except Exception:
        print(f"{ICON_MUTED}")

def display_volume():
    """Display volume icon and percentage (minimal)"""
    try:
        vol = get_volume()
        muted = is_muted()
        
        if muted:
            print(f"{ICON_MUTED}")
        else:
            # Volume icons based on level
            if vol == 0:
                icon = "󰖁"
            elif vol < 30:
                icon = "󰕿"
            elif vol < 70:
                icon = "󰖀"
            else:
                icon = "󰕾"
            
            print(f"{icon} {vol}%")
    except Exception:
        print(f"{ICON_MUTED}")

def display_menu():
    """Show rofi menu to select audio device"""
    try:
        current_sink = get_default_sink()
        menu_items = []
        sink_map = {}
        
        # Get all sinks
        sinks_output = pactl("list short sinks")
        if not sinks_output:
            return
        
        for line in sinks_output.splitlines():
            if not line.strip():
                continue
            parts = line.split("\t")
            if len(parts) >= 2:
                sink_name = parts[1]
                display_name = get_device_name(sink_name)
                
                if sink_name == current_sink:
                    menu_items.append(f"✓ {display_name}")
                else:
                    menu_items.append(f"  {display_name}")
                
                sink_map[display_name] = sink_name
        
        if not menu_items:
            return
        
        # Show rofi menu
        result = subprocess.run(
            ['rofi', '-dmenu', '-i', '-p', 'Audio Device', '-theme-str', 'window {width: 400px;}'],
            input="\n".join(menu_items),
            text=True,
            capture_output=True,
            timeout=100
        )
        
        if result.returncode == 0 and result.stdout.strip():
            selected = result.stdout.strip().replace("✓ ", "").replace("  ", "")
            if selected in sink_map:
                sink_name = sink_map[selected]
                pactl(f"set-default-sink {sink_name}")
                
                # Move all streams
                streams = pactl("list short sink-inputs")
                if streams:
                    for line in streams.splitlines():
                        if not line.strip():
                            continue
                        parts = line.split("\t")
                        if len(parts) > 0 and parts[0].isdigit():
                            stream_id = parts[0]
                            pactl(f"move-sink-input {stream_id} {sink_name}")
                
                notify("Áudio", f"Dispositivo alterado: {selected}")
    except Exception:
        pass

def main():
    if len(sys.argv) < 2:
        display_volume()
        return
    
    cmd = sys.argv[1]
    if cmd == "change-sink":
        change_sink()
    elif cmd == "vol-up":
        set_volume(5)
    elif cmd == "vol-down":
        set_volume(-5)
    elif cmd == "mute":
        toggle_mute()
    elif cmd == "audio":
        display_audio()
    elif cmd == "volume":
        display_volume()
    elif cmd == "menu":
        display_menu()
    else:
        display_volume()

if __name__ == "__main__":
    main()