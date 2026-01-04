# Minecraft GitOps Server

Este proyecto implementa un servidor de Minecraft moderno utilizando prácticas de **GitOps**. La idea principal es que la imagen de Docker contiene **toda** la configuración, plugins y mods necesarios. Kubernetes solo se encarga de ejecutar esa imagen y persistir el mundo (`world`).

## 🏗 Arquitectura

1.  **Docker Build**: Github Actions construye una imagen de Docker basada en `itzg/minecraft-server:java21`.
2.  **Inyección de Contenido**: Copiamos plugins, configs y scripts dentro de la imagen en `/opt/gitops`.
3.  **Entrypoint Custom**: Al arrancar el contenedor en K8s, un script (`gitops-entrypoint.sh`) sincroniza los archivos desde `/opt/gitops` hacia `/data` (donde vive el servidor real).
4.  **Despliegue Helm**: Github Actions usa Helm para desplegar la nueva imagen en tu cluster.

## 🚀 Requisitos Previos

Para que el pipeline de CI/CD funcione, necesitas configurar los siguientes **Secrets** en tu repositorio de GitHub (Settings -> Secrets and variables -> Actions):

| Secret | Descripción |
| :--- | :--- |
| `DOCKER_USERNAME` | Tu usuario de Docker Hub (ej: `nicodav28`) |
| `DOCKER_PASSWORD` | Tu Token de acceso o contraseña de Docker Hub |
| `KUBE_CONFIG` | El contenido completo de tu archivo `~/.kube/config` para acceder a tu cluster K8s. |

## 📂 Estructura del Proyecto

*   `docker/`: Archivos que se inyectan en la imagen.
    *   `configs/`: Configs de plugins y mods.
    *   `static-plugins/`: Jars de plugins que no se bajan de internet automáticamente.
    *   `scripts/`: Scripts de utilidad (entrypoint).
*   `helm/`: Chart de Helm (usamos `itzg/minecraft-server` con un values custom).
*   `.github/workflows/`: Pipelines de CI/CD.

## 🛠 Cómo agregar Mods/Plugins

### Mods/Plugins descargables (URL)
Edita `helm/minecraft-values.yaml` y agrégalos a las listas:
*   `minecraftServer.modUrls`: Para Mods de Forge.
*   `minecraftServer.pluginUrls`: Para Plugins de Bukkit/Spigot.

*Ventaja*: No engordan la imagen de Docker. Se bajan al arrancar el pod.

### Configs y Plugins "Manuales"
Pon los archivos en:
*   `docker/configs/config/`: Para archivos de configuración de mods.
*   `docker/configs/plugins/`: Para carpetas de configuración de plugins (ej: `Essentials/config.yml`).
*   `docker/static-plugins/`: Para `.jar` que tengas descargados localmente.

*Ventaja*: Control total de versiones y configuración vía Git.

## 🔄 Flujo de Trabajo

1.  Haces cambios en local (agregas un mod, cambias una config).
2.  `git commit` y `git push` a la rama `main`.
3.  Github Actions:
    *   Construye la nueva imagen Docker.
    *   La sube a Docker Hub.
    *   Le dice a tu cluster Kubernetes: "Actualízate a la versión `v1.0.X`".
4.  Kubernetes baja la imagen, reinicia el pod y ¡listo!

## 🧪 Testing Local

Puedes probar que la imagen se construye bien antes de subir:

```bash
docker build -t minecraft-test .
```

Y correrla (smoke test):

```bash
docker run -it --rm -e EULA=TRUE minecraft-test
```
