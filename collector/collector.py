#!/usr/bin/python3

import signal
import sys
import os
import logging
import wm
import time
import pygame

lorem = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed aliquet
tellus eros, eu faucibus dui. Phasellus eleifend, massa id ornare sodales, est urna
congue tellus, vitae varius metus nunc non enim. Mauris elementum, arcu vitae tempor euismod, justo turpis malesuada est, sed dictum nunc nulla nec mauris. Cras felis eros, elementum vitae sollicitudin in, elementum et augue. Proin eget nunc at dui congue pretium. Donec ut ipsum ut lacus mollis tristique. In pretium varius dui eu dictum.

Proin pulvinar metus nec mi semper semper. Pellentesque habitant morbi tristique
senectus et netus et malesuada fames ac turpis egestas. Proin in diam odio. Vestibulum
at neque sed ante sodales eleifend quis id dui. Mauris sollicitudin, metus a semper consectetur,
est lectus varius erat, sit amet ultrices tortor nisi id justo. Aliquam elementum vestibulum dui ut auctor. Mauris commodo sapien vitae augue tempus sagittis. Morbi a nibh lectus, sed porta nibh. Donec et est ac dui sodales aliquet tristique et arcu. Nullam enim felis, posuere vel rutrum eu, euismod a purus. Morbi porta cursus libero, id rutrum elit lacinia vitae.

In condimentum ultrices ipsum, ut convallis odio egestas et. Cras at egestas elit. Morbi
quis neque ligula. Sed tempor, sem at fringilla rhoncus, diam quam mollis nisi, vitae semper
mi massa sit amet tellus. Vivamus congue commodo ornare. Morbi et mi non sem malesuada rutrum. Etiam est purus, interdum ut placerat sit amet, tempus eget eros. Duis eget augue quis diam facilisis blandit. Ut vulputate adipiscing eleifend. """

class App:
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
            wm.Button("Retry", self.retry),
            wm.Button("Data", self.data),
        ]

        w.add(wm.MenuSystem(menu_bounds, buttons, 2, 2))
        w.add(wm.Messages(messages_bounds))
        w.add(wm.Cursor())
        w.run()

    def restart(self, w):
        sys.exit(0)

    def reboot(self, w):
        w.stop()
        time.sleep(1.0)
        os.system("reboot")

    def logs(self, w):
        pass

    def retry(self, w):
        pass

    def data(self, w):
        font = pygame.font.Font("determinationmonoweb-webfont.ttf", 14)
        text_wall = wm.TextWall(font, lorem, w.bounds)

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

    def signal_handler(sig, frame):
        logging.info('Terminating')
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)

    os.putenv('SDL_VIDEODRIVER', 'fbcon')
    os.putenv('SDL_FBDEV', '/dev/fb0')

    app = App()
    app.run()

if __name__== "__main__":
    main()
