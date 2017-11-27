package main

import (
	// "time"
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/guregu/dynamo"
)

// Use struct tags much like the standard JSON library,
// you can embed anonymous structs too!
type widget struct {
	UserID int       // Hash key, a.k.a. partition key
	// Time   time.time // Range key, a.k.a. sort key
	Time   int // Range key, a.k.a. sort key

	Msg       string              `dynamo:"Message"`
	// Count     int                 `dynamo:",omitempty"`
	// Friends   []string            `dynamo:",set"` // Sets
	// Set       map[string]struct{} `dynamo:",set"` // Map sets, too!
	// SecretKey string              `dynamo:"-"`    // Ignored
	// Children  []any               // Lists
}


func main() {
	fmt.Println("start")
	db := dynamo.New(session.New(), &aws.Config{Region: aws.String("ap-northeast-1"), Endpoint: aws.String("http://localhost:8000")})
	table := db.Table("Widgets")

	// put item
	// w := widget{UserID: 613, Time: time.Now(), Msg: "hello"}
	w := widget{UserID: 612, Time: 666, Msg: "hello"}
	err := table.Put(w).Run() 
	if (nil != err) {
		fmt.Println(err)
	}
	// get the same item 
	var result widget
	// err = table.Get("UserID", w.UserID).
	// 	Range("Time", dynamo.Equal, w.Time).
	// 	Filter("'Count' = ? AND $ = ?", w.Count, "Message", w.Msg). // placeholders in expressions
	// 	One(&result)
	err = table.Get("UserID", w.UserID).
		Range("Time", dynamo.Equal, w.Time).
		One(&result)
	fmt.Println(result)
	// get all items
	var results []widget
	err = table.Scan().All(&results)
	fmt.Println(results)
}