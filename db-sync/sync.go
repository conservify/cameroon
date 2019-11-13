package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	"strings"
	"time"

	"database/sql"

	_ "github.com/lib/pq"

	"github.com/tatsushid/go-fastping"
)

type Options struct {
	Help           bool
	WatchIP        string
	SourceURL      string
	DestinationURL string
}

type Synchronizer struct {
	LastSync time.Time
}

func NewSynchronizer() (s *Synchronizer) {
	return &Synchronizer{}
}

func (s *Synchronizer) DumpDatabase(o *Options) error {
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

func (s *Synchronizer) CopyTableUsingSql(o *Options, table string, source, destiny *sql.DB) error {
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

	if false {
		log.Printf("%s", insertionQuery)
	}

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

func (s *Synchronizer) Synchronize(o *Options) error {
	source, err := sql.Open("postgres", o.SourceURL)
	if err != nil {
		return err
	}

	defer source.Close()

	destiny, err := sql.Open("postgres", o.DestinationURL)
	if err != nil {
		return err
	}

	defer destiny.Close()

	tables := []string{"device_up", "device_ack", "device_join", "device_location", "device_status", "device_error"}

	for _, table := range tables {
		err := s.CopyTableUsingSql(o, table, source, destiny)
		if err != nil {
			return err
		}
	}

	err = s.DumpDatabase(o)
	if err != nil {
		return err
	}

	return nil
}

func (s *Synchronizer) Check(ip string) (bool, error) {
	success := false

	p := fastping.NewPinger()
	p.AddIP(ip)
	p.OnRecv = func(addr *net.IPAddr, rtt time.Duration) {
		if false {
			log.Printf("IP Addr: %s receive, RTT: %v", addr.String(), rtt)
		}
		success = true
	}
	p.OnIdle = func() {
		if !success {
			log.Println("no reply")
		}
	}

	err := p.Run()
	if err != nil {
		return false, err
	}

	return success, nil
}

func (s *Synchronizer) ShouldSync() bool {
	seconds := time.Now().Sub(s.LastSync).Seconds()
	if seconds > 300 {
		s.LastSync = time.Now()
		return true
	}
	return false
}

func (s *Synchronizer) Watch(o *Options) error {
	for {
		found, err := s.Check(o.WatchIP)
		if err != nil {
			log.Println("Error", err)
		}

		if found {
			if s.ShouldSync() {
				err := s.Synchronize(o)
				if err != nil {
					log.Println("Error", err)
				}
			}
		}

		time.Sleep(1 * time.Second)
	}

	return nil
}

func main() {
	o := &Options{}

	flag.BoolVar(&o.Help, "help", false, "help")
	flag.StringVar(&o.SourceURL, "source", "", "source")
	flag.StringVar(&o.DestinationURL, "destination", "", "destination")
	flag.StringVar(&o.WatchIP, "watch", "", "watch")
	flag.Parse()

	if o.Help || o.SourceURL == "" || o.DestinationURL == "" {
		flag.Usage()
		os.Exit(2)
		return
	}

	s := NewSynchronizer()

	if o.WatchIP != "" {
		if err := s.Watch(o); err != nil {
			log.Fatal(err)
		}
	} else {
		if err := s.Synchronize(o); err != nil {
			log.Fatal(err)
		}
	}
}
