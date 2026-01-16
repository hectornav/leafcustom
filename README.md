# Leafcustom - Overleaf Community Edition Personalizado

Configuración personalizada de [Overleaf Community Edition](https://github.com/overleaf/overleaf) para implementación local con Docker. Este repositorio incluye scripts de automatización para facilitar la instalación y gestión en Ubuntu Server.

## 📋 Descripción

Overleaf es un editor LaTeX colaborativo en tiempo real de código abierto. Esta versión personalizada (Leafcustom) está optimizada para:
- Instalación rápida en Ubuntu/Debian
- Scripts de gestión automatizados
- Configuración lista para entornos locales/privados
- Gestión simplificada de usuarios

> [!CAUTION]
> **Importante:** Overleaf Community Edition está diseñado para entornos donde **todos** los usuarios son de confianza. NO es apropiado para escenarios que requieren aislamiento de usuarios, ya que no incluye compilación sandbox. Los usuarios tienen acceso completo a los recursos del contenedor `sharelatex` durante las compilaciones LaTeX.

## 🚀 Instalación Rápida en Ubuntu Server

### Requisitos Previos
- Ubuntu/Debian Server
- Cuenta con privilegios `sudo`
- Conexión a Internet

### Instalación Automatizada

```bash
# 1. Clonar el repositorio
git clone https://github.com/hectornav/leafcustom.git
cd leafcustom

# 2. Ejecutar bootstrap (instala Docker y dependencias)
sudo ./scripts/bootstrap.sh

# 3. Iniciar los servicios
./scripts/start.sh

# 4. Inicializar MongoDB (si es necesario)
./scripts/init_mongo_replicaset.sh

# 5. Crear usuario administrador
./scripts/create_admin_user.sh --email=admin@ejemplo.com --admin

# 6. Verificar estado
./scripts/check_health.sh
```

La aplicación estará disponible en `http://localhost` o `http://<IP-DEL-SERVIDOR>`

## 👥 Gestión de Usuarios

### ⚠️ Importante sobre Registro de Usuarios

**Overleaf Community Edition NO permite registro público por defecto** por razones de seguridad. Los usuarios deben ser creados manualmente por el administrador del servidor.

### Crear Usuario Administrador

```bash
./scripts/create_admin_user.sh --email=admin@ejemplo.com --admin
```

### Crear Usuario Normal

```bash
./create_overleaf_user.sh --email=usuario@ejemplo.com
```

### Crear Usuario con Contenedor Específico

```bash
./create_overleaf_user.sh --email=usuario@ejemplo.com --admin --container=leafcustom-sharelatex-1
```

### Método Manual (Avanzado)

```bash
# Acceder al contenedor web
docker exec -it leafcustom-sharelatex-1 /bin/bash

# Crear usuario desde dentro del contenedor
node services/web/modules/server-ce-scripts/scripts/create-user.js --email=usuario@ejemplo.com --admin
```

## 🛠️ Scripts Disponibles

El directorio `scripts/` contiene herramientas de gestión:

| Script | Descripción |
|--------|-------------|
| `bootstrap.sh` | Instala Docker, Docker Compose y prepara el sistema |
| `start.sh` | Inicia todos los servicios con Docker Compose |
| `stop.sh` | Detiene todos los servicios |
| `start_and_show.sh` | Inicia servicios y muestra logs en tiempo real |
| `init_mongo_replicaset.sh` | Inicializa el replicaset de MongoDB |
| `create_admin_user.sh` | Crea un usuario administrador |
| `check_health.sh` | Verifica el estado de los contenedores |
| `kill_server.sh` | Fuerza el cierre de todos los servicios |

## 🐳 Gestión con Docker Compose

### Comandos Básicos

```bash
# Iniciar servicios en segundo plano
docker compose up -d

# Ver estado de contenedores
docker ps

# Ver logs en tiempo real
docker compose logs -f

# Ver logs de un servicio específico
docker logs -f leafcustom-sharelatex-1

# Detener servicios
docker compose down

# Reiniciar un servicio
docker compose restart sharelatex

# Reconstruir e iniciar
docker compose up -d --build
```

## 🔧 Configuración

### Variables de Entorno Importantes

Edita `docker-compose.yml` para configurar:

```yaml
environment:
  # URL del sitio
  SHARELATEX_SITE_URL: 'http://tu-servidor.com'
  
  # Configuración SMTP (para emails)
  SHARELATEX_EMAIL_FROM_ADDRESS: 'noreply@ejemplo.com'
  SHARELATEX_EMAIL_SMTP_HOST: 'smtp.gmail.com'
  SHARELATEX_EMAIL_SMTP_PORT: 587
  SHARELATEX_EMAIL_SMTP_USER: 'tu-email@gmail.com'
  SHARELATEX_EMAIL_SMTP_PASS: 'tu-contraseña'
  
  # Permitir registro público (NO RECOMENDADO)
  # SHARELATEX_ALLOW_PUBLIC_ACCESS: 'true'
```

### MongoDB Replicaset

Overleaf requiere MongoDB configurado como replicaset. Si ves errores de conexión:

```bash
# Inicializar manualmente
docker exec -it leafcustom-mongo-1 mongosh --eval 'rs.initiate({_id: "overleaf", members: [{ _id: 0, host: "localhost:27017" }]})'

# O usar el script incluido
./scripts/init_mongo_replicaset.sh
```

## 🔒 Seguridad

### Recomendaciones para Producción

1. **NO exponer directamente a Internet** sin protección adicional
2. **Configurar HTTPS** con un proxy inverso (nginx, Caddy, Traefik)
3. **Configurar firewall** para limitar acceso
4. **Cambiar credenciales por defecto** de MongoDB y Redis
5. **Realizar backups regulares** de datos
6. **Mantener Docker actualizado**
7. **Considerar Overleaf Server Pro** para sandboxing y SSO

### Configurar HTTPS (Recomendado)

Usar Caddy como proxy inverso:

```bash
# Instalar Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy

# Configurar Caddyfile
sudo nano /etc/caddy/Caddyfile
```

```
tu-dominio.com {
    reverse_proxy localhost:80
}
```

```bash
sudo systemctl reload caddy
```

## 📁 Estructura del Repositorio

```
leafcustom/
├── docker-compose.yml          # Configuración de servicios Docker
├── create_overleaf_user.sh     # Script para crear usuarios
├── SETUP.md                    # Guía detallada de configuración
├── scripts/                    # Scripts de automatización
│   ├── bootstrap.sh
│   ├── start.sh
│   ├── stop.sh
│   ├── create_admin_user.sh
│   └── ...
├── services/                   # Código de los servicios Overleaf
├── libraries/                  # Librerías compartidas
└── server-ce/                  # Configuración del servidor CE
```

## 🔍 Solución de Problemas

### El servicio no inicia

```bash
# Ver logs detallados
docker compose logs -f

# Verificar estado de contenedores
docker ps -a

# Reiniciar servicios
docker compose restart
```

### Error de conexión a MongoDB

```bash
# Verificar que MongoDB esté corriendo
docker ps | grep mongo

# Inicializar replicaset
./scripts/init_mongo_replicaset.sh
```

### No puedo acceder a la interfaz web

```bash
# Verificar que el puerto 80 esté abierto
sudo netstat -tulpn | grep :80

# Verificar configuración de firewall
sudo ufw status

# Si es necesario, abrir puerto
sudo ufw allow 80/tcp
```

### Los usuarios no pueden compilar

```bash
# Verificar que Docker socket esté montado
docker inspect leafcustom-sharelatex-1 | grep docker.sock

# Reiniciar el servicio sharelatex
docker compose restart sharelatex
```

## 📚 Documentación Adicional

- [Documentación oficial de Overleaf](https://github.com/overleaf/overleaf/wiki)
- [Overleaf Toolkit](https://github.com/overleaf/toolkit/)
- [Guía de configuración detallada](SETUP.md)

## 🤝 Contribuir

Este proyecto es una personalización de Overleaf Community Edition. Para contribuciones al proyecto original, visita el [repositorio oficial de Overleaf](https://github.com/overleaf/overleaf).

## 📄 Licencia

Este código se distribuye bajo la licencia GNU AFFERO GENERAL PUBLIC LICENSE, versión 3. Consulta el archivo [LICENSE](LICENSE) para más detalles.

Copyright (c) Overleaf, 2014-2025.

---

## 💡 Notas Finales

- **Este repositorio NO es el oficial de Overleaf**, es una versión personalizada con scripts de automatización
- Para soporte empresarial y características avanzadas (SSO, sandboxing), considera [Overleaf Server Pro](https://www.overleaf.com/for/enterprises)
- Mantén tu instalación actualizada revisando el [repositorio oficial](https://github.com/overleaf/overleaf)
