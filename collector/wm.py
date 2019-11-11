import pygame
import time
import datetime
import logging

import calibrated_touch_events

class WindowObject:
    def draw(self, display):
        pass

    def mouse_down(self, wm, p):
        return False

    def mouse_up(self, wm, p):
        return False

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
                return True
        return False

    def mouse_up(self, wm, p):
        for button in self.children:
            if button.pressed:
                button.up(wm)
                return True
        return False

class Messages(WindowObject):
    def __init__(self, bounds):
        self.bounds = bounds

    def draw(self, display):
        pygame.draw.rect(display, (255, 255, 255), self.bounds, 2)

class Cursor(WindowObject):
    def __init__(self):
        self.bounds = pygame.Rect((0, 0, 0, 0))

    def mouse_down(self, wm, p):
        self.bounds = pygame.Rect((p[0] - 5, p[1] - 5, 10, 10))

    def draw(self, display):
        pygame.draw.rect(display, (255, 0, 255), self.bounds, 2)

class Window:
    def __init__(self):
        self.children = []
        self.xres = 480
        self.yres = 320
        self.bounds = pygame.Rect(0, 0, self.xres, self.yres)

    def add(self, child):
        self.children.append(child)

    def mouse_down(self, p):
        redraw = False
        for c in self.children:
            if c.mouse_down(self, p):
                redraw = True
        return redraw

    def mouse_up(self, p):
        redraw = False
        for c in self.children:
            if c.mouse_up(self, p):
                redraw = True
        return redraw

    def draw(self):
        self.display.fill((0, 0, 0))

        for c in self.children:
            c.draw(self.display)

        pygame.display.update()

        logging.info("draw")

    def run(self):
        logging.info("Starting...")

        pygame.init()
        pygame.mouse.set_visible(False)

        logging.info("SetMode...")
        self.display = pygame.display.set_mode((self.xres, self.yres))

        logging.info("Drawing...")

        self.draw()

        pygame.event.set_blocked((pygame.MOUSEBUTTONDOWN, pygame.MOUSEBUTTONUP, pygame.MOUSEMOTION))

        cme = calibrated_touch_events.CalibratedTouchEvents(self.xres, self.yres)

        down_at = None

        while True:
            for ev in cme.read():
                logging.info(str(ev))
                if ev.type == pygame.MOUSEBUTTONDOWN and not down_at:
                    down_at = datetime.datetime.now()
                    rel = pygame.mouse.get_rel()
                    p = pygame.mouse.get_pos()
                    if self.mouse_down(p):
                        self.draw()
                    pygame.event.clear()

                if ev.type == pygame.MOUSEBUTTONUP and down_at:
                    down_for = datetime.datetime.now() - down_at
                    down_at = None
                    p = pygame.mouse.get_pos()
                    if self.mouse_up(p):
                        self.draw()
                    pygame.event.clear()
                    print(down_for)

                if ev.type == pygame.QUIT:
                    logging.info("QUIT")
                    pygame.event.clear()

            time.sleep(0.02)
