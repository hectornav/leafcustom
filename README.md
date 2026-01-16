<h1 align="center">
  <br>
  <a href="https://www.overleaf.com"><img src="doc/logo.png" alt="Overleaf" width="300"></a>
</h1>

<h4 align="center">An open-source online real-time collaborative LaTeX editor.</h4>

<p align="center">
  <a href="https://github.com/overleaf/overleaf/wiki">Wiki</a> •
  <a href="https://www.overleaf.com/for/enterprises">Server Pro</a> •
  <a href="#contributing">Contributing</a> •
  <a href="https://mailchi.mp/overleaf.com/community-edition-and-server-pro">Mailing List</a> •
  <a href="#authors">Authors</a> •
  <a href="#license">License</a>
</p>

<img src="doc/screenshot.png" alt="A screenshot of a project being edited in Overleaf Community Edition">
<p align="center">
  Figure 1: A screenshot of a project being edited in Overleaf Community Edition.
</p>

## Community Edition

[Overleaf](https://www.overleaf.com) is an open-source online real-time collaborative LaTeX editor. We run a hosted version at [www.overleaf.com](https://www.overleaf.com), but you can also run your own local version, and contribute to the development of Overleaf.

> [!CAUTION]
> Overleaf Community Edition is intended for use in environments where **all** users are trusted. Community Edition is **not** appropriate for scenarios where isolation of users is required due to Sandbox Compiles not being available. When not using Sandboxed Compiles, users have full read and write access to the `sharelatex` container resources (filesystem, network, environment variables) when running LaTeX compiles.

For more information on Sandbox Compiles check out our [documentation](https://docs.overleaf.com/on-premises/configuration/overleaf-toolkit/server-pro-only-configuration/sandboxed-compiles).

## Enterprise

If you want help installing and maintaining Overleaf in your lab or workplace, we offer an officially supported version called [Overleaf Server Pro](https://www.overleaf.com/for/enterprises). It also includes more features for security (SSO with LDAP or SAML), administration and collaboration (e.g. tracked changes). [Find out more!](https://www.overleaf.com/for/enterprises)

## Keeping up to date

Sign up to the [mailing list](https://mailchi.mp/overleaf.com/community-edition-and-server-pro) to get updates on Overleaf releases and development.

## Installation

We have detailed installation instructions in the [Overleaf Toolkit](https://github.com/overleaf/toolkit/).

## Upgrading

If you are upgrading from a previous version of Overleaf, please see the [Release Notes section on the Wiki](https://github.com/overleaf/overleaf/wiki#release-notes) for all of the versions between your current version and the version you are upgrading to.

## Overleaf Docker Image

This repo contains two dockerfiles, [`Dockerfile-base`](server-ce/Dockerfile-base), which builds the
`sharelatex/sharelatex-base` image, and [`Dockerfile`](server-ce/Dockerfile) which builds the
`sharelatex/sharelatex` (or "community") image.

The Base image generally contains the basic dependencies like `wget`, plus `texlive`.
We split this out because it's a pretty heavy set of
dependencies, and it's nice to not have to rebuild all of that every time.

The `sharelatex/sharelatex` image extends the base image and adds the actual Overleaf code
and services.

Use `make build-base` and `make build-community` from `server-ce/` to build these images.

We use the [Phusion base-image](https://github.com/phusion/baseimage-docker)
(which is extended by our `base` image) to provide us with a VM-like container
in which to run the Overleaf services. Baseimage uses the `runit` service
manager to manage services, and we add our init-scripts from the `server-ce/runit`
folder.


## Contributing

Please see the [CONTRIBUTING](CONTRIBUTING.md) file for information on contributing to the development of Overleaf.

## Authors

[The Overleaf Team](https://www.overleaf.com/about)

## License

The code in this repository is released under the GNU AFFERO GENERAL PUBLIC LICENSE, version 3. A copy can be found in the [`LICENSE`](LICENSE) file.

Copyright (c) Overleaf, 2014-2025.

**Guía local (específica para este repo)**

- **Levantar los servicios (Docker / Docker Compose):**

  - Desde la raíz del repositorio corra:

    ```bash
    docker compose up -d
    ```

    Esto creará/arrancará los contenedores definidos (mongo, redis, sharelatex, etc.). Si en su entorno usa `docker-compose` en lugar del plugin `docker compose`, sustituya el comando por `docker-compose up -d`.

- **¿Qué es Docker Compose?**

  - `docker compose` (o `docker-compose`) es una herramienta que orquesta múltiples contenedores Docker descritos en un archivo `docker-compose.yml`. Permite declarar servicios, volúmenes, redes y variables de entorno para ejecutar pilas completas con un único comando.

- **Comprobar estado:**

  - Ver contenedores en ejecución:

    ```bash
    docker ps
    ```

  - Ver logs del servicio web (sharelatex):

    ```bash
    docker logs -f <nombre_contenedor>
    ```

- **Parar / matar procesos:**

  - Parar la pila gestionada por Compose:

    ```bash
    docker compose down
    ```

  - Parar un contenedor individualmente:

    ```bash
    docker stop <nombre_contenedor>
    docker rm <nombre_contenedor>   # eliminar si desea recrearlo
    ```

- **Cómo añadir usuarios (desde el servidor Overleaf):**

  - Este repositorio incluye un script dentro del servicio web para crear usuarios. Puede ejecutarlo desde dentro del contenedor web o usar el helper `create_overleaf_user.sh` incluido en la raíz del repositorio.

  - Uso recomendado (desde el host):

    ```bash
    ./create_overleaf_user.sh --email=usuario@ejemplo.com [--admin] [--container=CONTAINER_NAME]
    ```

    - `--admin` marca al usuario como administrador.
    - `--container` fuerza el nombre del contenedor donde está ejecutándose la app web (si no se indica, el script intentará detectarlo automáticamente).

  - El script invoca internamente el script oficial `services/web/modules/server-ce-scripts/scripts/create-user.*` dentro del contenedor, que creará el usuario en la base de datos y devolverá una URL para establecer la contraseña.

- **Añadir usuario manualmente (alternativa):**

  - Acceda al contenedor web y ejecute el script Node directamente:

    ```bash
    # obtener un shell en el contenedor (reemplazar <container>)
    docker exec -it <container> /bin/bash

    # desde el shell del contenedor
    node services/web/modules/server-ce-scripts/scripts/create-user.js --email=usuario@ejemplo.com --admin
    ```

- **Acceder a la interfaz web:**

  - Si ejecutó `docker compose` en la misma máquina, abra `http://localhost` o `http://<IP_DEL_SERVIDOR>` en un navegador.

- **Notas importantes sobre MongoDB y replicaset:**

  - Overleaf espera que MongoDB esté configurado como replicaset (aunque sea de una sola instancia). Si Mongo no fue inicializado como replicaset, la aplicación mostrará errores de conexión. Para inicializar manualmente:

    ```bash
    docker exec -it <mongo_container> mongosh --eval 'rs.initiate({_id: "overleaf", members: [{ _id: 0, host: "localhost:27017" }]})'
    ```

  Nota rápida: este repositorio monta automáticamente `/var/run/docker.sock` en el servicio `sharelatex` (docker-compose.yml) para que el subsistema de compilación (CLSI) pueda ejecutar contenedores de compilado. Si después de actualizar compose ve errores de compilación, reinicie la pila con `./scripts/start_and_show.sh`.

- **Seguridad y advertencias:**

  - Overleaf Community Edition no proporciona compilación sandbox por defecto en esta configuración; NO exponga este servidor a Internet sin medidas adicionales (firewall, HTTPS, autenticación SSO, sandboxing de compilados).

  - Antes de exponer servicios al resto de la red, configure `SITE_URL`, SMTP y credenciales admin en el archivo de entorno/`docker-compose.yml` según la documentación oficial.

---

Archivo helper para crear usuarios: [create_overleaf_user.sh](create_overleaf_user.sh)
