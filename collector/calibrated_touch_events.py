import events
import calibration
import pygame

class CalibratedTouchEvents:
    def __init__(self, xres, yres):
        self.calib = calibration.load()
        self.xres = xres
        self.yres = yres
        self.mouse_pos = None
        self.mouse_down = False
        self.down = None

    def read(self):
        evs, sys_evs = [], events.read_raw_events()
        for e in sys_evs:
            if e.down is not None:
                self.down = e.down
                if not self.down and self.mouse_down and self.mouse_pos:
                    evs.append(pygame.event.Event(pygame.MOUSEBUTTONUP, button=1, pos=self.mouse_pos))
                    self.mouse_down = False

            if e.pos is not None:
                screen_pos = calibration.to_screen(e.pos, (self.xres, self.yres), self.calib)
                if self.down:
                    if not self.mouse_down:
                        evs.append(pygame.event.Event(pygame.MOUSEBUTTONDOWN, button=1, pos=screen_pos))
                        self.mouse_down = True
                    elif self.mouse_pos and self.mouse_pos != screen_pos:
                        evs.append(pygame.event.Event(
                            pygame.MOUSEMOTION, buttons=(1, 0, 0), pos=screen_pos, rel=(screen_pos[0] - self.mouse_pos[0], screen_pos[1] - self.mouse_pos[1])
                        ))
                self.mouse_pos = screen_pos
                #pygame.mouse.set_pos(*screen_pos)

        return evs
