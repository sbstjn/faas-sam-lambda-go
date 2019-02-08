package main

import (
	"context"
	"errors"
	"fmt"
	"os"
)

type event struct {
	ShouldFail bool `json:"should_fail"`
}

func handle(ctx context.Context, e event) (string, error) {
	fmt.Printf("%s invoked", os.Getenv("ProjectID"))

	if e.ShouldFail == true {
		return "", errors.New("Failed on purpose")
	}

	return "Success", nil
}
