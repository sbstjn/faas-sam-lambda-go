PROJECT_NAME = sam-lambda-go

include .faas

test:
	@ go test ./...

build:
	@ GOOS=linux go build -o dist/handler ./src
