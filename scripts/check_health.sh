#!/usr/bin/env bash
set -euo pipefail

echo "== Comprobación rápida de estado Overleaf (contenedores) =="
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

echo
echo "== Puertos expuestos (grep 80/443/3000) =="
ss -tulpn | grep -E ':80|:443|:3000' || true

echo
echo "== Logs recientes del contenedor web (sharelatex) =="
WEB=$(docker ps --filter "ancestor=sharelatex/sharelatex" --format '{{.Names}}' | head -n1 || true)
if [ -n "$WEB" ]; then
  echo "Contenedor web: $WEB -- mostrando últimos 200 líneas"
  docker logs --tail 200 "$WEB" || true
else
  echo "No se detectó contenedor web 'sharelatex'"
fi
