package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"

	"database/sql"

	_ "github.com/lib/pq"
)

type Options struct {
	Help           bool
	SourceURL      string
	DestinationURL string
}

func dumpDatabase(o *Options) error {
	log.Println("backing up database")

	cmd := exec.Command("pg_dump", o.SourceURL)

	incoming, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}

	now := time.Now()
	timeString := now.Format("20060102_150405")
	outgoing, err := os.Create(fmt.Sprintf("%s.pgdump", timeString))
	if err != nil {
		return err
	}

	defer outgoing.Close()

	if err := cmd.Start(); err != nil {
		return err
	}

	scanner := bufio.NewScanner(incoming)

	for scanner.Scan() {
		line := scanner.Text()
		outgoing.WriteString(line)
		outgoing.WriteString("\n")
	}

	cmd.Wait()

	return nil
}

func copyTableUsingSql(o *Options, table string, source, destiny *sql.DB) error {
	log.Println("copying", table)

	rows, err := source.Query(fmt.Sprintf("SELECT * FROM %s", table))
	if err != nil {
		return err
	}

	defer rows.Close()

	columns, err := rows.Columns()
	if err != nil {
		return err
	}

	variables := make([]string, len(columns))
	values := make([]interface{}, len(columns))
	for i, _ := range columns {
		values[i] = new(sql.RawBytes)
		variables[i] = fmt.Sprintf("$%d", i+1)
	}

	insertionQuery := fmt.Sprintf("INSERT INTO %s (%s) VALUES (%s) ON CONFLICT DO NOTHING", table, strings.Join(columns, ", "), strings.Join(variables, ", "))
	inserter, err := destiny.Prepare(insertionQuery)
	if err != nil {
		return err
	}

	log.Printf("%s", insertionQuery)

	for rows.Next() {
		err = rows.Scan(values...)
		if err != nil {
			return err
		}

		_, err := inserter.Exec(values...)
		if err != nil {
			return err
		}
	}

	return nil
}

func main() {
	o := &Options{}
	flag.BoolVar(&o.Help, "help", false, "help")

	flag.StringVar(&o.SourceURL, "source", "", "source")
	flag.StringVar(&o.DestinationURL, "destination", "", "destination")

	flag.Parse()

	if o.Help {
		flag.Usage()
		os.Exit(2)
		return
	}

	err := dumpDatabase(o)
	if err != nil {
		log.Fatal(err)
	}

	source, err := sql.Open("postgres", o.SourceURL)
	if err != nil {
		log.Fatal(err)
	}

	destiny, err := sql.Open("postgres", o.DestinationURL)
	if err != nil {
		log.Fatal(err)
	}

	tables := []string{"device_up", "device_ack", "device_join", "device_location", "device_status", "device_error"}

	for _, table := range tables {
		err := copyTableUsingSql(o, table, source, destiny)
		if err != nil {
			log.Fatal(err)
		}
	}
}
