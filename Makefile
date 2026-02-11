# Define the shell
SHELL := /bin/bash

.PHONY: all up down logs

# Default target
all: up

up: certs
	@# Check if config.yaml exists
	@if [ -f config.yaml ]; then \
		echo "--- ✅ Found 'config.yaml'. Skipping pre-flight script. ---"; \
	else \
		echo "--- ⚠️ 'config.yaml' not found. Running pre-flight script... ---"; \
		chmod +x gas-station-tool.sh; \
		SCRIPT_OUTPUT=$$(./gas-station-tool.sh generate-sample-config --config-path config.yaml --docker-compose -n testnet -f); \
		ADDRESS=$$(echo "$$SCRIPT_OUTPUT" | cut -d "'" -f 2); \
		echo "--- 🚀 Funding address $$ADDRESS ---"; \
		curl --location 'https://faucet.testnet.iota.cafe/gas' \
		--header 'Content-Type: application/json' \
		--data '{ "FixedAmountRequest": { "recipient": "'"$$ADDRESS"'" } }'; \
		echo "--- ✅ DONE ---"; \
	fi

	@echo "--- 🐳 Starting Docker Compose ---"
	docker compose up --build -d

down:
	@echo "--- Stopping Docker Compose ---"
	docker compose down

logs:
	docker compose logs -f

reset:
	@echo "--- Resetting docker containers ---"
	docker compose down -v
	
	@echo "--- Starting docker containers ---"
	docker compose up --build -d

	@echo "--- 🚀 Done!!! ---"


# ===============================
# Local TLS setup using mkcert
# ===============================

CERTS_DIR := certs
CERT_FILE := $(CERTS_DIR)/fullchain.pem
KEY_FILE  := $(CERTS_DIR)/privkey.pem

# Domains to generate certs for
# Override like:
# make certs DOMAINS="api.local.test localhost"
DOMAINS ?= app.supply-chain.localhost api.supply-chain.localhost ::1

.PHONY: certs clean check-mkcert install-mkcert

## Default target
certs: check-mkcert install-ca generate-certs
	@echo "✅ TLS certs generated in $(CERTS_DIR)/"

## Check if mkcert is installed
check-mkcert:
	@command -v mkcert >/dev/null 2>&1 || $(MAKE) install-mkcert

## Install mkcert via Homebrew
install-mkcert:
	@echo "🔧 Installing mkcert via Homebrew..."
	@command -v brew >/dev/null 2>&1 || (echo "❌ Homebrew is required"; exit 1)
	@brew install mkcert nss

## Install local CA (idempotent)
install-ca:
	@echo "🔐 Installing local CA (if not already installed)..."
	@mkcert -install

## Generate certificates
generate-certs:
	@mkdir -p $(CERTS_DIR)
	@echo "📄 Generating certs for: $(DOMAINS)"
	@mkcert \
		-key-file $(KEY_FILE) \
		-cert-file $(CERT_FILE) \
		$(DOMAINS)

## Clean generated certs
clean:
	@rm -rf $(CERTS_DIR)
	@echo "🧹 Removed $(CERTS_DIR)/"
