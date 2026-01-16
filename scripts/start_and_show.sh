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
echo "Arrancando la pila con ${COMPOSE_CMD[*]}..."
"${COMPOSE_CMD[@]}" up -d

# Detectar contenedor web
WEB=$(docker ps --filter "ancestor=sharelatex/sharelatex" --format '{{.Names}}' | head -n1 || true)
if [ -z "$WEB" ]; then
  WEB=$(docker ps --format '{{.Names}} {{.Image}}' | grep -i sharelatex | awk '{print $1}' | head -n1 || true)
fi

echo "Esperando a que la interfaz responda en http://localhost (timeout 120s)..."
ready=false
for i in {1..60}; do
  if curl -s --max-time 2 http://localhost/ >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 2
done

if [ "$ready" = true ]; then
  echo "Servicio web disponible."
else
  echo "Advertencia: la interfaz no respondió en http://localhost dentro del tiempo límite. Revise logs con './scripts/check_health.sh' o 'docker logs <container>'."
fi

# Obtener IP local de la máquina (LAN)
LAN_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
if [ -z "$LAN_IP" ]; then
  LAN_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ { print $7 }' || true)
fi

echo
echo "=== Información de acceso ==="
echo "Interfaz (localhost): http://localhost"
if [ -n "$LAN_IP" ]; then
  echo "Interfaz (LAN): http://$LAN_IP"
fi
if [ -n "$WEB" ]; then
  echo "Contenedor web: $WEB"
  echo "Ver logs: docker logs -f $WEB"
fi

# Verificar que /var/run/docker.sock esté montado en el contenedor web; si no, recrearlo para aplicar el montaje
if [ -n "$WEB" ]; then
  MOUNTED=$(docker inspect -f '{{range .Mounts}}{{.Destination}} {{end}}' "$WEB" 2>/dev/null || true)
  if ! echo "$MOUNTED" | grep -qw /var/run/docker.sock; then
    echo "\nAdvertencia: el contenedor '$WEB' no tiene /var/run/docker.sock montado. Intentando recrear 'sharelatex' para aplicar la nueva configuración..."
    set +e
    "${COMPOSE_CMD[@]}" stop sharelatex >/dev/null 2>&1 || true
    "${COMPOSE_CMD[@]}" rm -f sharelatex >/dev/null 2>&1 || true
    "${COMPOSE_CMD[@]}" up -d sharelatex || {
      echo "Error: no se pudo recrear el servicio 'sharelatex' automáticamente. Revise docker-compose.yml y arranque manualmente." >&2
    }
    set -e
    echo "Se ha intentado reiniciar 'sharelatex' con la nueva configuración. Compruebe logs: docker logs -f $WEB"
  fi
fi

echo
echo "Para crear un usuario admin ejecute: ./scripts/create_admin_user.sh --email=you@example.com --admin"
echo "Para detener y eliminar la pila: ./scripts/kill_server.sh"
