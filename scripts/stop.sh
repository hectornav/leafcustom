#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PRUNE=false
for arg in "$@"; do
  case "$arg" in
    --prune) PRUNE=true ;; 
    -h|--help) echo "Usage: $0 [--prune]"; exit 0 ;;
  esac
done

detect_compose() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD=(docker compose)
  elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD=(docker-compose)
  else
    echo "Error: neither 'docker compose' nor 'docker-compose' found" >&2
    exit 1
  fi
}

detect_compose
if [ "$PRUNE" = true ]; then
  echo "Parando y eliminando volúmenes: ${COMPOSE_CMD[*]} down -v"
  "${COMPOSE_CMD[@]}" down -v
else
  echo "Parando la pila: ${COMPOSE_CMD[*]} down"
  "${COMPOSE_CMD[@]}" down
fi
