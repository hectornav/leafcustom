# Guía rápida de instalación en un PC nuevo

Este documento explica cómo dejar operativo Overleaf Community Edition en un PC nuevo usando Docker. Incluye scripts útiles en la carpeta `scripts/` para automatizar pasos comunes.

Requisitos mínimos
- Linux (estas instrucciones están orientadas a Debian/Ubuntu; los scripts intentan detectar y avisar en otros sistemas)
- Cuenta con privilegios `sudo`

Resumen de pasos
1. Ejecutar `scripts/bootstrap.sh` para instalar Docker y dependencias básicas.
2. Ejecutar `scripts/start.sh` para arrancar la pila con `docker compose`.
3. Inicializar el replicaset de Mongo si es necesario: `scripts/init_mongo_replicaset.sh`.
4. Crear un usuario admin: `scripts/create_admin_user.sh --email=admin@ejemplo.com --admin`.

Archivos y scripts incluidos
- `scripts/bootstrap.sh` — instala Docker, Docker Compose (plugin), y prepara el sistema.
- `scripts/start.sh` — ejecuta `docker compose up -d` desde la raíz del repo.
- `scripts/stop.sh` — para la pila con `docker compose down`.
- `scripts/init_mongo_replicaset.sh` — inicializa el replicaset de Mongo (por defecto `overleaf`).
- `scripts/create_admin_user.sh` — wrapper para crear un usuario admin (usa `create_overleaf_user.sh`).
- `scripts/check_health.sh` — comprobaciones básicas (contenedores en ejecución y puertos).

Uso recomendado (ejemplo)

```bash
# 1) Ejecutar bootstrap (requiere sudo)
sudo ./scripts/bootstrap.sh

# 2) Arrancar la pila
./scripts/start.sh

# 3) Inicializar replicaset (si docker-compose no lo hizo)
./scripts/init_mongo_replicaset.sh --container=mongo --replset=overleaf

# 4) Crear un admin
./scripts/create_admin_user.sh --email=you@example.com --admin

# 5) Verificar estado
./scripts/check_health.sh
```

Notas y recomendaciones
- Revise `docker compose` vs `docker-compose` según su sistema; los scripts usan `docker compose` por defecto.
- No exponga este servidor en Internet sin medidas de seguridad (HTTPS, firewall, sandbox de compilados, SMTP configurado).

Si necesita soporte para otra distribución (RHEL/CentOS/Fedora), pídemelo y adapto los scripts.
