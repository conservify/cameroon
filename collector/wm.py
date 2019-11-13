import pygame
import time
import datetime
import logging
import queue

import calibrated_touch_events

Padding = 5

class WindowObject:
    def __init__(self):
        self.visible = True
        self.dirty = False

    def draw(self, display):
        self.dirty = True

    def mouse_down(self, wm, p):
        return False

    def mouse_up(self, wm, p):
        return False

    def tick(self, wm):
        return False

    def show(self):
        self.visible = True
        self.dirty = True

    def hide(self):
        self.visible = False
        self.dirty = True

class Button(WindowObject):
    def __init__(self, label, handler, bg=(50, 177, 255)):
        super(Button, self).__init__()
        self.label = label
        self.handler = handler
        self.bg = bg
        self.border = None
        self.pressed = False

    def down(self, wm):
        if self.enabled():
            self.pressed = True

    def up(self, wm):
        if self.pressed:
            logging.info(self.label)
            self.handler(wm)
            self.pressed = False

    def is_inside(self, test):
        if not self.border:
            return False
        return self.border.collidepoint(test)

    def draw(self, display, r):
        black = (0, 0, 0)
        white = (255, 255, 255)
        bg = self.bg
        fg = white

        if self.pressed:
            bg = white
            fg = black

        border = r.inflate(-Padding, -Padding)

        if bg:
            pygame.draw.rect(display, bg, border)

        pygame.draw.rect(display, fg, border, 2)

        f = pygame.font.Font('freesansbold.ttf', 32)
        text = f.render(self.label, True, fg, None)
        textRect = text.get_rect()
        textRect.center = (r.x + r.w / 2, r.y + r.h / 2)
        display.blit(text, textRect)

        self.border = r

    def enabled(self):
        return True

class MenuSystem(WindowObject):
    def __init__(self, bounds, buttons, ncolumns, nrows):
        super(MenuSystem, self).__init__()
        self.bounds = bounds
        self.ncolumns = ncolumns
        self.nrows = nrows
        self.children = buttons

    def draw(self, display):
        black = (0, 0, 0)
        white = (255, 255, 255)

        if False: pygame.draw.rect(display, white, self.bounds, 2)

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
        super(Messages, self).__init__()
        self.bounds = bounds.inflate(-Padding, -Padding)
        self.font = None
        self.status = None
        self.queue = queue.Queue()
        self.queue.put("Hello, there! I'm ready for data, have a good and safe hike!")

    def inbox(self):
        return self.queue.put

    def draw(self, display):
        if False: pygame.draw.rect(display, (255, 255, 255), self.bounds, 2)

        if not self.font:
            self.font = pygame.font.Font("determinationmonoweb-webfont.ttf", 16)

        if self.status:
            text_wall = TextWall(self.font, self.status, self.bounds)
            text_wall.draw(display, (255, 255, 255))

    def tick(self, wm):
        dirty = False
        while not self.queue.empty():
            new_status = self.queue.get()
            if self.status != new_status:
                self.status = new_status
                dirty = True
        return dirty

class Cursor(WindowObject):
    def __init__(self):
        super(Cursor, self).__init__()
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
            if c.visible:
                if c.mouse_down(self, p):
                    redraw = True
        return redraw

    def mouse_up(self, p):
        redraw = False
        for c in self.children:
            if c.visible:
                if c.mouse_up(self, p):
                    redraw = True
        return redraw

    def tick(self):
        redraw = False
        for c in self.children:
            if c.tick(self):
                redraw = True
        return redraw

    def draw(self):
        self.display.fill((0, 0, 0))

        for c in self.children:
            if c.visible:
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
                    logging.info("%s" % (down_for))

                if ev.type == pygame.QUIT:
                    logging.info("QUIT")
                    pygame.event.clear()

            if self.tick():
                self.draw()

            time.sleep(0.02)

    def stop(self):
        pygame.display.quit()

    def show(self):
        pygame.display.init()
        pygame.mouse.set_visible(False)
        self.display = pygame.display.set_mode((self.xres, self.yres))

class TextLine:
    def __init__(self, line, rect, font):
        self.line = line
        self.rect = rect
        self.font = font

    def draw(self, surface, color, viewport, translate):
        new_bounds = self.rect.move(translate)
        if viewport.contains(new_bounds):
            image = self.font.render(self.line, False, color)
            surface.blit(image, (new_bounds.left, new_bounds.top))

    def __str__(self):
        return "TextLine<%s, %s>" % (self.rect, self.line)


def autosize_line(text, rect, font):
    line = None
    size = None
    for i in range(1, len(text) + 1):
        test_line = text[:i].strip()
        test_size = font.size(test_line)
        if test_size[0] < rect.width:
            line = test_line
            size = test_size
        else:
            j = text.rfind(" ", 0, i) + 1
            line = text[:j].strip()
            size = font.size(line)
            return line, text[j:], size

    return line, None, size

def break_wrapped(surface, all_text, rect, font):
    line_spacing = -2
    rect = pygame.Rect(rect)
    necessary = pygame.Rect(rect.x, rect.y, 0, 0)
    y = rect.top
    lines = []

    for text in all_text.split("\n"):
        while text:
            line, text, size = autosize_line(text, rect, font)

            line_rect = pygame.Rect(rect.left, y, size[0], size[1] + line_spacing)

            lines.append(TextLine(line, line_rect, font))

            y += size[1] + line_spacing

            if necessary.w < size[0]:
                necessary.w = size[0]

            necessary.h += size[1] + line_spacing

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
        hidden = 0
        ty = 0
        for i, tl in enumerate(broken):
            if i < self.offset:
                ty += tl.rect.h
                continue
            tl.draw(surface, color, bounds, (0, -ty))
