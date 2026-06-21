CARGO ?= cargo
BIN_NAME := clean-copy
INSTALL_DIR := ../bin
INSTALL_PATH := $(INSTALL_DIR)/$(BIN_NAME)

.PHONY: build release install test fmt clippy check clean

build:
	$(CARGO) build

release:
	$(CARGO) build --release

install: release
	mkdir -p $(INSTALL_DIR)
	cp target/release/$(BIN_NAME) $(INSTALL_PATH)
	chmod 755 $(INSTALL_PATH)

test:
	$(CARGO) test

fmt:
	$(CARGO) fmt --all -- --check

clippy:
	$(CARGO) clippy --all-targets -- -D warnings

check: fmt clippy test

clean:
	$(CARGO) clean
