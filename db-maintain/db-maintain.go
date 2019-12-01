package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"reflect"

	"database/sql"

	"encoding/csv"
	"encoding/hex"

	_ "github.com/lib/pq"
)

type Options struct {
	Help        bool
	Delete      bool
	DatabaseURL string
	ArchivePath string
	MaximumSize int
}

type Maintainer struct {
}

func NewMaintainer() (s *Maintainer) {
	return &Maintainer{}
}

func (m *Maintainer) Maintain(o *Options) error {
	log.Println("running db mainenance")

	db, err := sql.Open("postgres", o.DatabaseURL)
	if err != nil {
		return err
	}

	defer db.Close()

	tables := []string{"device_up", "device_ack", "device_join", "device_location", "device_status", "device_error"}

	for _, table := range tables {
		err := m.ShrinkTable(db, table, o)
		if err != nil {
			return err
		}
	}

	return nil
}

func (m *Maintainer) ShrinkTable(db *sql.DB, table string, o *Options) error {
	for {
		size := 0
		rows := 0
		err := db.QueryRow(fmt.Sprintf("SELECT pg_total_relation_size('%s') AS size, COUNT(*) AS rows FROM %s", table, table)).Scan(&size, &rows)
		if err != nil {
			return err
		}

		log.Printf("%s table size = %v, rows = %v\n", table, size, rows)

		if size < o.MaximumSize {
			return nil
		}

		nrows, err := m.ShrinkTableOnce(db, table, o)
		if err != nil {
			return err
		}

		if nrows == 0 {
			return nil
		}

		if !o.Delete {
			return nil
		}
	}

	return nil
}

func (m *Maintainer) ShrinkTableOnce(db *sql.DB, table string, o *Options) (int32, error) {
	tx, err := db.Begin()
	if err != nil {
		return 0, err
	}

	nrows := int32(0)
	err = db.QueryRow(fmt.Sprintf("SELECT COUNT(*) FROM %s", table)).Scan(&nrows)
	if err != nil {
		return 0, err
	}

	log.Printf("%s %d rows\n", table, nrows)

	if nrows == 0 {
		_, err = db.Query(fmt.Sprintf(fmt.Sprintf(`VACUUM FULL %s`, table)))
		if err != nil {
			return nrows, err
		}

		return nrows, nil
	}

	date := ""
	err = db.QueryRow(fmt.Sprintf("SELECT MIN(date_trunc('month', received_at)) FROM %s", table)).Scan(&date)
	if err != nil {
		return nrows, err
	}

	rows, err := db.Query(fmt.Sprintf(`SELECT * FROM %s WHERE date_trunc('month', received_at) = $1`, table), date)
	if err != nil {
		return nrows, err
	}

	if fi, err := os.Stat(o.ArchivePath); err != nil || !fi.IsDir() {
		return nrows, fmt.Errorf("archive path is missing: %s", o.ArchivePath)
	}

	fn := fmt.Sprintf("%s/%s_%s.csv", o.ArchivePath, table, date)
	err = m.ExportToCSV(rows, fn)
	if err != nil {
		return nrows, err
	}

	if o.Delete {
		_, err := db.Query(fmt.Sprintf(`DELETE FROM %s WHERE date_trunc('month', received_at) = $1`, table), date)
		if err != nil {
			return nrows, err
		}

		_, err = db.Query(fmt.Sprintf(fmt.Sprintf(`VACUUM FULL %s`, table)))
		if err != nil {
			return nrows, err
		}
	} else {
		log.Printf("%s delete disabled\n", table)
	}

	log.Printf("%s exported %s\n", table, date)

	return nrows, tx.Commit()
}

func (m *Maintainer) ExportToCSV(rows *sql.Rows, file string) error {
	columns, err := rows.Columns()
	if err != nil {
		return err
	}

	types, err := rows.ColumnTypes()
	if err != nil {
		return err
	}

	rawColumns := make([][]byte, len(columns))
	strings := make([]string, len(columns))
	values := make([]interface{}, len(columns))
	for i, _ := range columns {
		values[i] = &rawColumns[i]
	}

	f, err := os.Create(file)
	if err != nil {
		return err
	}

	defer f.Close()

	w := csv.NewWriter(f)

	defer w.Flush()

	err = w.Write(columns)
	if err != nil {
		return err
	}

	nrows := 0
	for rows.Next() {
		err = rows.Scan(values...)
		if err != nil {
			return err
		}

		for i, raw := range rawColumns {
			if raw == nil {
				strings[i] = "\\N"
			} else {
				if IsByteArrayType(types[i].ScanType()) {
					strings[i] = hex.EncodeToString(raw)
				} else {
					strings[i] = string(raw)
				}
			}
		}

		err := w.Write(strings)
		if err != nil {
			return err
		}

		nrows += 1
	}

	return nil
}

func IsByteArrayType(t reflect.Type) bool {
	var x []uint8
	return reflect.TypeOf(x) == t
}

func main() {
	o := &Options{}

	flag.BoolVar(&o.Help, "help", false, "help")
	flag.BoolVar(&o.Delete, "delete", false, "delete")

	flag.StringVar(&o.DatabaseURL, "database", "", "database")
	flag.StringVar(&o.ArchivePath, "archive", "./", "archive")

	flag.IntVar(&o.MaximumSize, "size", 0, "size")

	flag.Parse()

	m := NewMaintainer()

	err := m.Maintain(o)
	if err != nil {
		log.Fatal(err)
	}
}
