#!/usr/bin/python3

import signal
import sys
import os
import logging
import wm

def main():
    logging.basicConfig(format='%(asctime)-15s %(message)s', level=logging.INFO)

    def signal_handler(sig, frame):
        logging.info('Terminating')
        sys.exit(0)
        logging.info('Ok?')

    signal.signal(signal.SIGINT, signal_handler)

    os.putenv('SDL_VIDEODRIVER', 'fbcon')
    os.putenv('SDL_FBDEV', '/dev/fb0')
    os.putenv('SDL_MOUSEDRV', 'TSLIB')
    os.putenv('SDL_MOUSEDEV', '/dev/input/event0')

    w = wm.Window()
    bounds = w.bounds

    menu_bounds = bounds.copy()
    menu_bounds.h -= 80

    messages_bounds = bounds.copy()
    messages_bounds.y = menu_bounds.h
    messages_bounds.h = 80

    w.add(wm.MenuSystem(menu_bounds))
    w.add(wm.Messages(messages_bounds))
    w.add(wm.Cursor())
    w.run()

if __name__== "__main__":
    main()
