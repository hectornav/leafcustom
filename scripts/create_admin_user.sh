#!/usr/bin/env bash
set -euo pipefail

EMAIL=""
ADMIN=false
CONTAINER=""

for arg in "$@"; do
  case "$arg" in
    --email=*) EMAIL="${arg#*=}" ;; 
    --admin) ADMIN=true ;; 
    --container=*) CONTAINER="${arg#*=}" ;; 
    -h|--help) echo "Usage: $0 --email=you@example.com [--admin] [--container=CONTAINER]"; exit 0 ;;
    *) echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

if [ -z "$EMAIL" ]; then
  echo "--email is required" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ -z "$CONTAINER" ]; then
  # try to detect the web container
  CONTAINER=$(docker ps --filter "ancestor=sharelatex/sharelatex" --format '{{.Names}}' | head -n1 || true)
fi

if [ -z "$CONTAINER" ]; then
  echo "Could not detect web container. Start the stack first or set --container." >&2
  exit 2
fi

echo "Using container: $CONTAINER"

./create_overleaf_user.sh --email="$EMAIL" $( [ "$ADMIN" = true ] && echo --admin ) --container="$CONTAINER"
