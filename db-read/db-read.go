package main

import (
	"context"
	"flag"
	"log"
	"os"

	_ "github.com/lib/pq"

	"github.com/conservify/sqlxcache"

	"github.com/golang/protobuf/proto"

	pb "github.com/fieldkit/data-protocol"
)

type Options struct {
	Help bool
	URL  string
}

type LoraAppDatabase struct {
	DB *sqlxcache.DB
}

type LoraRecordReceiver interface {
	HandleLoraRecord(up *DeviceUp, record *pb.LoraRecord) error
}

func NewLoraAppDatabase() (ldb *LoraAppDatabase) {
	return &LoraAppDatabase{}
}

func (ldb *LoraAppDatabase) Open(url string) error {
	db, err := sqlxcache.Open("postgres", url)
	if err != nil {
		return err
	}

	ldb.DB = db

	return nil
}

func (ldb *LoraAppDatabase) ProcessAll(ctx context.Context, receiver LoraRecordReceiver) error {
	uplinks := []*DeviceUp{}
	if err := ldb.DB.SelectContext(ctx, &uplinks, `SELECT id, received_at, dev_eui, f_cnt, f_port, data, object FROM device_up ORDER BY f_cnt`); err != nil {
		log.Fatal(err)
	}

	for _, u := range uplinks {
		record := &pb.LoraRecord{}
		err := proto.Unmarshal(u.Data, record)
		if err == nil {
			err = receiver.HandleLoraRecord(u, record)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

type MainLoraRecordReceiver struct {
}

func (lrr *MainLoraRecordReceiver) HandleLoraRecord(u *DeviceUp, record *pb.LoraRecord) error {
	log.Printf("%v %v %v", u.ReceivedAt.Format("2006/0102 15:04:05"), u.DeviceEUIAsString(), record)
	return nil
}

func main() {
	ctx := context.Background()

	o := &Options{}
	flag.BoolVar(&o.Help, "help", false, "help")

	flag.StringVar(&o.URL, "url", "", "url")

	flag.Parse()

	if o.Help {
		flag.Usage()
		os.Exit(2)
		return
	}

	ldb := NewLoraAppDatabase()

	if err := ldb.Open(o.URL); err != nil {
		log.Fatal(err)
	}

	lrr := &MainLoraRecordReceiver{}

	if err := ldb.ProcessAll(ctx, lrr); err != nil {
		log.Fatal(err)
	}
}
