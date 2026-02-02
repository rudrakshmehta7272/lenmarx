.PHONY: install build test clean help

BINARY_NAME=lenmarxd
MAIN_PATH=./cmd/lenmarxd
VERSION=$(shell git describe --tags --always --dirty 2>/dev/null || echo "0.1.0")
LDFLAGS=-ldflags="-X github.com/cosmos/cosmos-sdk/version.Name=lenmarx -X github.com/cosmos/cosmos-sdk/version.Version=$(VERSION)"

help:
	@echo "LENMARX Blockchain Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make build       - Build the lenmarxd binary"
	@echo "  make install     - Install lenmarxd to \$$GOPATH/bin"
	@echo "  make test        - Run tests"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make lint        - Run linters"
	@echo "  make fmt         - Format code"
	@echo ""

build:
	@echo "Building $(BINARY_NAME)..."
	go build $(LDFLAGS) -o ./build/$(BINARY_NAME) $(MAIN_PATH)
	@echo "✓ Binary created at ./build/$(BINARY_NAME)"

install:
	@echo "Installing $(BINARY_NAME)..."
	go install $(LDFLAGS) $(MAIN_PATH)
	@echo "✓ $(BINARY_NAME) installed to \$$GOPATH/bin"

test:
	@echo "Running tests..."
	go test -v -race ./...

lint:
	@echo "Running linters..."
	golangci-lint run ./...

fmt:
	@echo "Formatting code..."
	go fmt ./...

clean:
	@echo "Cleaning build artifacts..."
	rm -rf ./build/$(BINARY_NAME)
	go clean -cache -testcache
	@echo "✓ Clean complete"

deps:
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy
	@echo "✓ Dependencies updated"

.PHONY: build install test clean lint fmt help deps
