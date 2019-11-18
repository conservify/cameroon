import os
import sys
import logging
import threading
import collections
import subprocess
import blkinfo
import pyudev
import json
import time
import tempfile

import psycopg2
import psycopg2.extras

class Worker:
    def start(self):
        self.thread = threading.Thread(target=self.run, args=())
        self.thread.daemon = True
        self.thread.start()

    def is_alive(self):
        return self.thread.is_alive()

    def run(self):
        logging.info("started worker")
        self.work()
        logging.info("done")

class Summary(collections.namedtuple("Summary", "uplinks joins uplinks_size joins_size")):
        __slots__ = ()
        def __str__(self):
            return "(uplinks=%d, size=%d)" % (self.uplinks, self.uplinks_size)

class Synchronizer(Worker):
    def __init__(self, options, status):
        self.options = options
        self.status = status
        self.thread = None
        self.tables = ["device_up", "device_ack", "device_join", "device_location", "device_status", "device_error"]

        psycopg2.extras.register_default_json(loads=lambda x: x)
        psycopg2.extras.register_default_jsonb(loads=lambda x: x)

    def query(self, source, sql):
        c = None
        try:
            c = source.cursor()
            c.execute(sql)
            return c.fetchone()
        finally:
            if c: c.close()

    def get_summary(self, db):
        uplinks = self.query(db, "SELECT COUNT(*) AS uplinks FROM device_up")[0]
        uplinks_size, joins_size = self.query(db, "SELECT pg_total_relation_size('device_up') / (1024.0 * 1024.0) AS uplinks_size, pg_total_relation_size('device_join') / (1024.0 * 1024.0) AS joins_size")

        return Summary(uplinks=uplinks, joins=0, uplinks_size=uplinks_size, joins_size=joins_size)

    def check_for_gateway(self):
        return subprocess.call(["ping", '-c', '1', "192.168.1.30"]) == 0

    def work(self):
        self.status("trying")

        source = None
        destiny = None

        try:
            logging.info("source %s" % (self.options.source,))
            logging.info("destiny %s" % (self.options.destiny,))

            source = psycopg2.connect(self.options.source)
            destiny = psycopg2.connect(self.options.destiny)

            self.status("querying summary...")

            local_summary_before = self.get_summary(destiny)
            remote_summary = self.get_summary(source)

            logging.info("local: %s" % (local_summary_before,))
            logging.info("remote: %s" % (remote_summary,))

            self.status("local: %s\nremote: %s" % (local_summary_before, remote_summary))

            for table in self.tables:
                query = source.cursor()
                try:
                    self.status("%s syncing %s" % (local_summary_before, table))
                    logging.info("querying %s" % (table))
                    query.execute("SELECT * FROM %s" % (table))

                    num_fields = len(query.description)
                    names = [c.name for c in query.description]
                    values = ["%s"] * num_fields
                    insertionQuery = "INSERT INTO %s (%s) VALUES (%s) ON CONFLICT DO NOTHING" % (table, ", ".join(names), ", ".join(values))

                    nrows = 0
                    for row in query.fetchall():
                        insertion = destiny.cursor()
                        insertion.execute(insertionQuery, row)
                        insertion.close()
                        nrows += 1

                    destiny.commit()

                    logging.info("done after %d rows" % (nrows,))

                finally:
                    query.close()

            local_summary_after = self.get_summary(destiny)

            new_uplinks = local_summary_after.uplinks - local_summary_before.uplinks

            self.status("local: %s\nremote: %s\nnew uplinks: %d" % (local_summary_after, remote_summary, new_uplinks))
        except psycopg2.OperationalError as e:
            logging.info("error: %s" % (e,))
            self.status("error syncing: %s" % (e,))
        except:
            e = sys.exc_info()[0]
            logging.info("error: %s" % (e,))
            self.status("error syncing: %s" % (e,))
        finally:
            if source: source.close()
            if destiny: destiny.close()

class Monitor(Worker):
    def __init__(self, options, status):
        self.options = options
        self.status = status
        self.thread = None
        self.context = pyudev.Context()
        self.monitor = pyudev.Monitor.from_netlink(self.context)
        self.monitor.filter_by(subsystem='usb')
        self.seen = {}

    def work(self):
        while True:
            time.sleep(1)

            try:
                found = {}
                for device in self.context.list_devices(subsystem='block', DEVTYPE='partition'):
                    dev_name = device.get('DEVNAME')
                    if device.get('ID_USB_DRIVER'):
                        if dev_name not in self.seen:
                            logging.info("{} {} {}".format(dev_name, device.get('DEVTYPE'), device.get('ID_USB_DRIVER')))
                            self.copy_to(dev_name)
                        self.seen[dev_name] = True
                        found[dev_name] = True

                remove = []
                for dev_name in self.seen.keys():
                    if dev_name not in found:
                        remove.append(dev_name)
                for dev_name in remove:
                    logging.info("removed %s" % (dev_name,))
                    self.status("removed %s!" % (device,))
                    del self.seen[dev_name]
            except:
                e = sys.exc_info()[0]
                logging.info("error: %s" % (e,))

    def mount_device(self, device):
        mp = tempfile.mkdtemp()
        logging.info("mounting %s on %s" % (device, mp))

        m = subprocess.call(["mount", device, mp])
        if m != 0:
            os.rmdir(mp)
            logging.info('mounting failed %s' % (m,))
            return None

        return mp

    def unmount(self, mp):
        if subprocess.call(["umount", mp]) != 0:
            logging.info('unmounting failed')
        try:
            os.rmdir(mp)
        except:
            e = sys.exc_info()[0]
            logging.info("error: %s" % (e,))

    def copy_to(self, device):
        self.status("exporting to %s..." % (device,))

        mp = self.mount_device(device)
        if not mp:
            return False

        try:
            logging.info("done!")
            self.status("successfully exported to %s!" % (device,))
            return True
        except:
            e = sys.exc_info()[0]
            logging.info("error: %s" % (e,))
        finally:
            self.unmount(mp)

class Exporter(Worker):
    def __init__(self, options, status):
        self.options = options
        self.status = status
        self.thread = None

    def work(self):
        self.status("exporting")
        self.status("done exporting")
