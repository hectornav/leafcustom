#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

detect_compose() {
	if docker compose version >/dev/null 2>&1; then
		echo "Using 'docker compose'"
		COMPOSE_CMD=(docker compose)
	elif command -v docker-compose >/dev/null 2>&1; then
		echo "Using 'docker-compose'"
		COMPOSE_CMD=(docker-compose)
	else
		echo "Error: neither 'docker compose' nor 'docker-compose' was found in PATH" >&2
		exit 1
	fi
}

detect_compose
echo "Arrancando servicios with ${COMPOSE_CMD[*]}..."

