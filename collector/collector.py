#!/usr/bin/python3

import signal
import sys
import os
import argparse
import logging
import wm
import time
import pygame
import subprocess
import queue
import sync

class App:
    def __init__(self, options):
        self.options = options
        self.task = None

    def run(self):
        w = wm.Window()
        bounds = w.bounds

        menu_bounds = bounds.copy()
        menu_bounds.h -= 80

        messages_bounds = bounds.copy()
        messages_bounds.y = menu_bounds.h
        messages_bounds.h = 80

        buttons = [
            wm.Button("Restart", self.restart),
            wm.Button("Reboot", self.reboot),
            wm.Button("Logs", self.logs),
            wm.Button("Sync", self.sync),
        ]

        w.add(wm.MenuSystem(menu_bounds, buttons, 2, 2))
        w.add(wm.Messages(messages_bounds, self.status))
        w.add(wm.Cursor())
        w.run()

    def stop(self):
        self.s.stop()

    def sync(self, w):
        if self.task:
            if self.task.is_alive():
                logging.info("busy")
                return

        self.task = sync.Synchronizer(self.options)
        self.task.start()

    def status(self):
        return "status information"

    def restart(self, w):
        sys.exit(0)

    def reboot(self, w):
        w.stop()
        time.sleep(1.0)
        os.system("reboot")

    def logs(self, w):
        w.stop()

        p = subprocess.Popen("tail -f /var/log/messages > /dev/tty0", shell=True, preexec_fn=os.setsid)
        try:
            looping = True
            while looping:
                for ev in w.read():
                    if ev.type == pygame.MOUSEBUTTONUP:
                        logging.info("stopping")
                        looping = False
                        break
        finally:
            logging.info("killing tail %s" % (p.pid))
            os.killpg(os.getpgid(p.pid), signal.SIGTERM)
        w.show()

    def data(self, w):
        font = pygame.font.Font("determinationmonoweb-webfont.ttf", 14)
        text_wall = wm.TextWall(font, "", w.bounds)

        w.display.fill((0, 0, 0))
        text_wall.draw(w.display, (255, 255, 255))
        pygame.display.update()

        stop = time.time() + 10
        while time.time() < stop:
            for ev in w.read():
                if ev.type == pygame.MOUSEBUTTONUP:
                    logging.info(str(ev))
                    if ev.pos[1] > 320 / 2:
                        text_wall.down()
                    else:
                        text_wall.up()
                w.display.fill((0, 0, 0))
                text_wall.draw(w.display, (255, 255, 255))
                pygame.display.update()
            time.sleep(0.2)

def main():
    logging.basicConfig(format='%(asctime)-15s %(message)s', level=logging.INFO)

    parser = argparse.ArgumentParser(description='Firmware Preparation Tool')
    parser.add_argument('--watch', dest="watch", default=None, help="")
    parser.add_argument('--source', dest="source", default=None, help="")
    parser.add_argument('--destiny', dest="destiny", default=None, help="")
    args, nargs = parser.parse_known_args()

    app = App(args)

    def signal_handler(sig, frame):
        logging.info('terminating')
        app.stop()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)

    os.putenv('SDL_VIDEODRIVER', 'fbcon')
    os.putenv('SDL_FBDEV', '/dev/fb0')

    app.run()

if __name__== "__main__":
    main()
