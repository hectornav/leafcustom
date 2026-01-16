#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

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
echo "Deteniendo pila con ${COMPOSE_CMD[*]} y eliminando volúmenes..."
"${COMPOSE_CMD[@]}" down -v --remove-orphans || true

echo "Eliminando contenedores residuales (sharelatex/mongo/redis) si existen..."
for img in sharelatex/sharelatex mongo:8 redis:6.2; do
  ids=$(docker ps -a --filter "ancestor=${img}" --format '{{.ID}}') || true
  if [ -n "$ids" ]; then
    echo "Eliminando contenedores de imagen $img: $ids"
    echo "$ids" | xargs -r docker rm -f || true
  fi
done

echo "Pila detenida y contenedores forzados eliminados."
