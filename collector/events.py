"""
Input events reader.

Collect events reading raw events pipe /dev/input/event0

Motivation:

The PS/2 emulated events available at /dev/input/mouse0 have
wrong position information if touch screen is used. So the pygame
relying on such events works incorrectly unless used under X-windows
system which implements its own raw events processing routine.

Adapted from the https://github.com/olegv142/pygamets project.
"""

import os
import struct
import collections

EV_KEY = 1
EV_ABS = 3

ABS_X = 0
ABS_Y = 1

EV_FMT = 'QHHI'
EV_SZ = struct.calcsize(EV_FMT)

events_filename = '/dev/input/event0'
events_file = None

def open_events_file():
    global events_file
    if events_file is None:
        # Select does not work for whatever reason on events file
        # so we have to use non-blocking mode
        fd = os.open(events_filename, os.O_RDONLY | os.O_NONBLOCK)
        events_file = os.fdopen(fd, "rb")
    return events_file

Event = collections.namedtuple('Event', ('down', 'pos'))

def read_raw_events():
    pos_x, pos_y = None, None
    events = []

    f = open_events_file()

    while True:
        try:
            e = f.read(EV_SZ)
        except IOError:
            break

        if e is None:
            break

        ts, type, code, val = struct.unpack(EV_FMT, e)
        if type == EV_KEY:
            down = val != 0
            events.append(Event(down, None))
        elif type == EV_ABS:
            if code == ABS_X: pos_x = val
            if code == ABS_Y: pos_y = val
            if pos_x and pos_y:
                events.append(Event(None, (pos_x, pos_y)))
                pos_x, pos_y = None, None

    return events
