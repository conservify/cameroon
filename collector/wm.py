import pygame
import time
import datetime
import logging

import calibrated_touch_events

class WindowObject:
    def __init__(self):
        self.visible = True

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
    def __init__(self, bounds, buttons, ncolumns, nrows):
        self.bounds = bounds
        self.ncolumns = ncolumns
        self.nrows = nrows
        self.children = buttons

    def draw(self, display):
        black = (0, 0, 0)
        white = (255, 255, 255)

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

    def read(self):
        return self.cme.read()

    def run(self):
        pygame.init()
        pygame.mouse.set_visible(False)

        self.display = pygame.display.set_mode((self.xres, self.yres))

        self.draw()

        print(pygame.font.get_fonts())

        pygame.event.set_blocked((pygame.MOUSEBUTTONDOWN, pygame.MOUSEBUTTONUP, pygame.MOUSEMOTION))

        self.cme = calibrated_touch_events.CalibratedTouchEvents(self.xres, self.yres)

        down_at = None

        while True:
            for ev in self.read():
                logging.info(str(ev))
                if ev.type == pygame.MOUSEBUTTONDOWN and not down_at:
                    down_at = datetime.datetime.now()
                    if self.mouse_down(ev.pos):
                        self.draw()
                    pygame.event.clear()

                if ev.type == pygame.MOUSEBUTTONUP and down_at:
                    down_for = datetime.datetime.now() - down_at
                    down_at = None
                    if self.mouse_up(ev.pos):
                        self.draw()
                    pygame.event.clear()
                    print(down_for)

                if ev.type == pygame.QUIT:
                    logging.info("QUIT")
                    pygame.event.clear()

            time.sleep(0.02)

    def stop(self):
        pygame.display.quit()

    def show(self):
        pygame.display.init()
        pygame.mouse.set_visible(False)
        self.display = pygame.display.set_mode((self.xres, self.yres))

class TextLine:
    def __init__(self, line, rect, font, visible):
        self.line = line
        self.rect = rect
        self.font = font
        self.visible = visible

    def draw(self, surface, color):
        image = self.font.render(self.line, False, color)
        surface.blit(image, (self.rect.left, self.rect.top))

    def __str__(self):
        return "TextLine<%s, %s, %s>" % (self.visible, self.rect, self.line)

def break_wrapped(surface, all_text, rect, font):
    line_spacing = -2
    rect = pygame.Rect(rect)
    necessary = pygame.Rect(rect.x, rect.y, 0, 0)
    y = rect.top
    lines = []

    for text in all_text.split("\n"):
        while text:
            i = 1

            while font.size(text[:i])[0] < rect.width and i < len(text):
                i += 1

            if i < len(text):
                i = text.rfind(" ", 0, i) + 1

            size = font.size(text[:i])

            visible = y + size[1] <= rect.bottom

            line_rect = pygame.Rect(rect.left, y, size[0], size[1] + line_spacing)

            lines.append(TextLine(text[:i], line_rect, font, visible))

            y += size[1] + line_spacing

            if necessary.w < size[0]:
                necessary.w = size[0]

            necessary.h += size[1] + line_spacing

            text = text[i:]

    return (necessary, lines)

class TextWall(object):
    def __init__(self, font, text, bounds):
        self.font = font
        self.text = text
        self.bounds = bounds
        self.remaining = None
        self.offset = 0

    def up(self):
        if self.offset > 0:
            self.offset -= 1

    def down(self):
        self.offset += 1

    def draw(self, surface, color):
        bounds = self.bounds.copy()
        b, broken = break_wrapped(surface, self.text, bounds, self.font)
        for tl in broken:
            if tl.visible:
                tl.draw(surface, color)
