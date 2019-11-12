import logging
import threading
import collections

import psycopg2
import psycopg2.extras

Summary = collections.namedtuple("Summary", "uplinks downlinks joins")

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

class Synchronizer(Worker):
    def __init__(self, options):
        self.options = options
        self.tables = ["device_up", "device_ack", "device_join", "device_location", "device_status", "device_error"]
        self.thread = None

        psycopg2.extras.register_default_json(loads=lambda x: x)
        psycopg2.extras.register_default_jsonb(loads=lambda x: x)

    def get_summary(self, source):
        c = source.cursor()
        try:
            c.execute("SELECT COUNT(*) FROM device_up")
            uplinks = c.fetchone()[0]
            return Summary(uplinks=uplinks, downlinks=0, joins=0)
        finally:
            c.close()

    def check_for_gateway(self):
        return subprocess.call(["ping", '-c', '1', "192.168.1.30"]) == 0

    def work(self):
        source = psycopg2.connect(self.options.source)
        destiny = psycopg2.connect(self.options.destiny)

        try:
            summary = self.get_summary(source)

            logging.info(summary)

            for table in self.tables:
                query = source.cursor()
                try:
                    logging.info("querying %s" % (table))
                    query.execute("SELECT * FROM %s" % (table))

                    num_fields = len(query.description)
                    names = [c.name for c in query.description]
                    values = ["%s"] * num_fields
                    insertionQuery = "INSERT INTO %s (%s) VALUES (%s) ON CONFLICT DO NOTHING" % (table, ", ".join(names), ", ".join(values))

                    for row in query.fetchall():
                        insertion = destiny.cursor()
                        insertion.execute(insertionQuery, row)
                        insertion.close()
                finally:
                    query.close()
        finally:
            if source: source.close()
            if destiny: destiny.close()
