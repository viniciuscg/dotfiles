#!/usr/bin/env python3

import subprocess
import sys
import re
import time

SINKS = [
    "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_3__sink",
    "alsa_output.usb-Corsair_CORSAIR_HS55_Wireless_Gaming_Receiver_79A71566FBCB0AC1-00.analog-stereo",
]

COLOR_GRAY   = "%{F#858585}"
COLOR_GREEN  = "%{F#98C379}"
COLOR_YELLOW = "%{F#D19A66}"
COLOR_RED    = "%{F#E06C75}"
COLOR_RESET  = "%{F-}"

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

def center(text, width):
    return text.center(width)

def get_default_sink():
    return pactl("get-default-sink")

def set_default_sink(sink):
    pactl(f"set-default-sink {sink}")

def move_streams():
    streams = pactl("list short sink-inputs")
    if not streams:
        return
    
    for line in streams.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) > 0 and parts[0].isdigit():
            stream_id = parts[0]
            pactl(f"move-sink-input {stream_id} @DEFAULT_SINK@")


def get_current_sink():
    out = pactl("list sink-inputs")
    if out:
        blocks = out.split("Sink Input #")[1:]
        for block in blocks:
            match = re.search(r"Sink:\s+(\S+)", block)
            if match:
                return match.group(1)

    return get_default_sink()


def change_sink():
    try:
        current_sink = get_default_sink()
        if not current_sink:
            return
        
        next_sink = SINKS[0] if current_sink == SINKS[1] else SINKS[1]
        pactl(f"set-default-sink {next_sink}")
        display_audio()
    except Exception:
        pass
 
def get_active_sink():
    return get_current_sink()

def set_volume(delta):
    sink = get_active_sink()
    sign = "+" if delta > 0 else ""
    pactl(f"set-sink-volume {sink} {sign}{delta}%")

def toggle_mute():
    try:
        sink = get_active_sink()
        if sink:
            pactl(f"set-sink-mute {sink} toggle")
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

def volume_color(vol, muted):
    if muted:
        return COLOR_GRAY
    if vol < 30:
        return COLOR_GREEN
    if vol < 70:
        return COLOR_YELLOW
    return COLOR_RED

def display_audio():
    try:
        sink = get_default_sink()
        if not sink:
            print(f"{COLOR_GRAY}{ICON_MUTED} No Audio{COLOR_RESET}")
            return
        
        vol = get_volume()
        muted = is_muted()
        icon = ICON_MUTED if muted else sink_icon(sink)
        color = volume_color(vol, muted)
        
        device_name = get_device_name(sink)
        print(f"{color} {icon} {device_name} {vol}%{COLOR_RESET}")
    except Exception:
        print(f"{COLOR_GRAY}{ICON_MUTED} Error{COLOR_RESET}")

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

def main():
    if len(sys.argv) < 2:
        display_audio()
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


if __name__ == "__main__":
    main()
