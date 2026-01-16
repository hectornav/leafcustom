#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --email=usuario@ejemplo.com [--admin] [--container=CONTAINER_NAME]

Creates an Overleaf user by invoking the built-in create-user script inside the web container.
If --container is not provided the script will try to detect the web container automatically.
EOF
  exit 1
}

EMAIL=""
ADMIN_FLAG=""
CONTAINER=""

for arg in "$@"; do
  case "$arg" in
    --email=*) EMAIL="${arg#*=}" ;; 
    --admin) ADMIN_FLAG="--admin" ;; 
    --container=*) CONTAINER="${arg#*=}" ;; 
    -h|--help) usage ;; 
    *) echo "Unknown arg: $arg"; usage ;;
  esac
done

if [ -z "$EMAIL" ]; then
  echo "Error: --email is required"
  usage
fi

if [ -z "$CONTAINER" ]; then
  # try to auto-detect container running the sharelatex image
  CONTAINER=$(docker ps --filter "ancestor=sharelatex/sharelatex" --format '{{.Names}}' | head -n1 || true)
fi

if [ -z "$CONTAINER" ]; then
  # fallback: any container exposing port 80 with sharelatex in its image name
  CONTAINER=$(docker ps --format '{{.Names}} {{.Image}}' | grep -i sharelatex | awk '{print $1}' | head -n1 || true)
fi

if [ -z "$CONTAINER" ]; then
  echo "Could not detect Overleaf web container. Please provide --container=NAME or run the web container first."
  exit 2
fi

echo "Using container: $CONTAINER"

POSSIBLE_PATHS=(
  "/var/www/sharelatex/services/web/modules/server-ce-scripts/scripts/create-user.js"
  "services/web/modules/server-ce-scripts/scripts/create-user.js"
  "/srv/sharelatex/services/web/modules/server-ce-scripts/scripts/create-user.js"
)

for p in "${POSSIBLE_PATHS[@]}"; do
  if docker exec "$CONTAINER" test -f "$p" >/dev/null 2>&1; then
    SCRIPT_PATH="$p"
    break
  fi
done

if [ -z "${SCRIPT_PATH-}" ]; then
  echo "Could not find create-user script inside container. Looked for: ${POSSIBLE_PATHS[*]}"
  exit 3
fi

echo "Found script: $SCRIPT_PATH"

CMD=(docker exec -it "$CONTAINER" node "$SCRIPT_PATH" --email="$EMAIL")
if [ -n "$ADMIN_FLAG" ]; then
  CMD+=(--admin)
fi

echo "Running: ${CMD[*]}"
"${CMD[@]}"

exit 0
