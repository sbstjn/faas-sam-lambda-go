PROJECT_SCOPE ?= faas
PROJECT_NAME ?= sam-lambda-go
ENV ?= stable
PROJECT_ID ?= $(PROJECT_SCOPE)-$(PROJECT_NAME)-$(ENV)

AWS_BUCKET_NAME ?= $(PROJECT_SCOPE)-artifacts
AWS_STACK_NAME ?= $(PROJECT_ID)
AWS_REGION ?= eu-west-1

FILE_TEMPLATE = infrastructure.yml
FILE_PACKAGE = ./dist/stack.yml

test:
	@ go test ./...

build:
	@ GOOS=linux go build -o dist/handler ./src

clean:
	@ rm -rf ./dist

configure:
	@ aws s3api create-bucket \
		--bucket $(AWS_BUCKET_NAME) \
		--region $(AWS_REGION) \
		--create-bucket-configuration LocationConstraint=$(AWS_REGION)

package:
	@ mkdir -p dist
	@ aws cloudformation package \
		--template-file $(FILE_TEMPLATE) \
		--s3-bucket $(AWS_BUCKET_NAME) \
		--region $(AWS_REGION) \
		--output-template-file $(FILE_PACKAGE)

deploy:
	@ aws cloudformation deploy \
		--template-file $(FILE_PACKAGE) \
		--region $(AWS_REGION) \
		--capabilities CAPABILITY_IAM \
		--stack-name $(AWS_STACK_NAME) \
		--force-upload \
		--parameter-overrides \
			ParamProjectID=$(PROJECT_ID) \
			ParamProjectScope=$(PROJECT_SCOPE) \
			ParamProjectName=$(PROJECT_NAME) \
			ParamENV=$(ENV)

destroy:
	@ aws cloudformation delete-stack \
		--stack-name $(AWS_STACK_NAME) \

describe:
	@ aws cloudformation describe-stacks \
		--region $(AWS_REGION) \
		--stack-name $(AWS_STACK_NAME)

outputs:
	@ make describe \
		| jq -r '.Stacks[0].Outputs'

.PHONY: configure package deploy describe outputs