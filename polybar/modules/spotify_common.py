#!/usr/bin/env python3

import dbus

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
    except Exception:
        return None, None

def is_spotify_running(properties):
    if properties is None:
        return False
    try:
        properties.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus')
        return True
    except Exception:
        return False

def get_playback_status(properties):
    if properties is None:
        return None
    try:
        return properties.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus')
    except Exception:
        return None

def get_metadata(properties):
    if properties is None:
        return None
    try:
        return properties.Get('org.mpris.MediaPlayer2.Player', 'Metadata')
    except Exception:
        return None

