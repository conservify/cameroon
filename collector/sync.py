import sys
import logging
import threading
import collections

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
            logging.info("remote: %s" % (local_summary_before,))

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

class Exporter(Worker):
    def __init__(self, options, status):
        self.options = options
        self.status = status
        self.thread = None

    def work(self):
        self.status("exporting")
        self.status("done exporting")
