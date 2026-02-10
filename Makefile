# Define the shell
SHELL := /bin/bash

.PHONY: all up down logs

# Default target
all: up

up:
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

	echo "--- 🔐 Generating SSL certificate. ---";
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/privkey.pem -out certs/fullchain.pem -subj "/CN=localhost"
	
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
