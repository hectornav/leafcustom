#!/usr/bin/env bash
set -euo pipefail

CONTAINER=${1:-mongo}
REPLSET=${2:-overleaf}

echo "Inicializando replicaset '$REPLSET' en contenedor Mongo: $CONTAINER"

docker exec -i "$CONTAINER" mongosh --quiet <<MONGO
rs.initiate({_id: "$REPLSET", members: [{ _id: 0, host: "localhost:27017" }]})
rs.status()
MONGO

echo "Replicaset iniciado. Revise logs si hay errores."
