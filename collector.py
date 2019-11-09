#!/usr/bin/python3

import pygame
import signal
import sys
import os
import time
import logging

class WindowObject:
    def draw(self, display):
        pass

    def mouse_down(self, wm, p):
        pass

    def mouse_up(self, wm, p):
        pass

class Button(WindowObject):
    def __init__(self, label, handler):
        self.label = label
        self.handler = handler
        self.border = None
        self.pressed = False

    def draw(self, display, r):
        black = (0, 0, 0)
        white = (255, 255, 255)
        bg = None
        fg = white

        if self.pressed:
            bg = white
            fg = black

        border = r.inflate(-5, -5)
        pygame.draw.rect(display, fg, border, 2)

        f = pygame.font.Font('freesansbold.ttf', 32)
        text = f.render(self.label, True, fg, bg)
        textRect = text.get_rect()
        textRect.center = (r.x + r.w / 2, r.y + r.h / 2)
        display.blit(text, textRect)

        self.border = r

    def is_inside(self, test):
        if not self.border: return False
        return self.border.collidepoint(test)

    def down(self, wm):
        self.pressed = True

    def up(self, wm):
        if self.pressed:
            logging.info(self.label)
            self.handler(wm)
            self.pressed = False

class MenuSystem(WindowObject):
    def __init__(self, bounds):
        self.bounds = bounds
        self.ncolumns = 2
        self.nrows = 2
        self.children = [
            Button("Restart", self.do_nothing),
            Button("Something", self.do_nothing),
            Button("Another", self.do_nothing),
            Button("Terminal", self.terminal),
        ]

    def draw(self, display):
        black = (0, 0, 0)
        white = (255, 255, 255)
        green = (0, 255, 0)
        blue = (0, 0, 128)

        pygame.draw.rect(display, white, self.bounds, 2)

        dw = self.bounds.w / self.ncolumns
        dh = self.bounds.h / self.nrows
        col = 0
        row = 0
        for button in self.children:
            x = self.bounds.x + (col * dw)
            y = self.bounds.y + (row * dh)
            r = pygame.Rect(x, y, dw, dh)
            button.draw(display, r)
            col += 1
            if col == self.ncolumns:
                col = 0
                row += 1

    def do_nothing(self, wm):
        logging.info("Nothing")

    def terminal(self, wm):
        logging.info("Terminal")

    def mouse_down(self, wm, p):
        for button in self.children:
            if button.is_inside(p):
                button.down(wm)

    def mouse_up(self, wm, p):
        for button in self.children:
            if button.pressed:
                button.up(wm)

class Messages(WindowObject):
    def __init__(self, bounds):
        self.bounds = bounds

    def draw(self, display):
        pygame.draw.rect(display, (255, 255, 255), self.bounds, 2)

class Window:
    def __init__(self):
        self.children = []
        self.xres = 480
        self.yres = 320
        self.bounds = pygame.Rect(0, 0, self.xres, self.yres)

    def add(self, child):
        self.children.append(child)

    def mouse_down(self, p):
        for c in self.children:
            c.mouse_down(self, p)

    def mouse_up(self, p):
        for c in self.children:
            c.mouse_up(self, p)

    def draw(self):
        self.display.fill((0, 0, 0))

        for c in self.children:
            c.draw(self.display)

        pygame.display.update()

    def run(self):
        logging.info("Starting...")

        pygame.init()
        pygame.mouse.set_visible(False)

        logging.info("SetMode...")
        self.display = pygame.display.set_mode((self.xres, self.yres))

        logging.info("Drawing...")

        self.draw()

        while True:
            for ev in pygame.event.get():
                if ev.type == pygame.MOUSEBUTTONDOWN:
                    original = pygame.mouse.get_pos()
                    p = (
                        int((      original[1]) / 320 * 480),
                        int((480 - original[0]) / 480 * 320)
                    )
                    logging.info("MOUSEBUTTONDOWN:%s %s" % (original, p))
                    self.mouse_down(p)
                    self.draw()
                    pygame.event.clear()
                if ev.type == pygame.MOUSEBUTTONUP:
                    original = pygame.mouse.get_pos()
                    p = (
                        int((      original[1]) / 320 * 480),
                        int((480 - original[0]) / 480 * 320)
                    )
                    logging.info("MOUSEBUTTONUP:%s %s" % (original, p))
                    self.mouse_up(p)
                    self.draw()
                    pygame.event.clear()
                if ev.type == pygame.QUIT:
                    logging.info("QUIT")
                    pygame.event.clear()

            time.sleep(0.1)

def main():
    logging.basicConfig(format='%(asctime)-15s %(message)s', level=logging.INFO)

    def signal_handler(sig, frame):
        logging.info('Terminating')
        sys.exit(0)
        logging.info('Ok?')

    signal.signal(signal.SIGINT, signal_handler)

    os.putenv('SDL_VIDEODRIVER', 'fbcon')
    os.putenv('SDL_FBDEV', '/dev/fb0')

    # I get weird mouse locations back with this.
    if False:
        os.putenv('SDL_MOUSEDRV', 'TSLIB')
        os.putenv('SDL_MOUSEDEV', '/dev/input/touchscreen')

    w = Window()
    bounds = w.bounds

    menu_bounds = bounds.copy()
    menu_bounds.h -= 80

    messages_bounds = bounds.copy()
    messages_bounds.y = menu_bounds.h
    messages_bounds.h = 80

    w.add(MenuSystem(menu_bounds))
    w.add(Messages(messages_bounds))
    w.run()

if __name__== "__main__":
    main()
