# Usamos la base de itzg
FROM itzg/minecraft-server:java21

LABEL maintainer="Nicolas Estevez"
LABEL type="GitOps-Ready"

# 1. Definimos las rutas de "Staging" (Donde guardaremos tu repo dentro de la imagen)
ENV GITOPS_DIR="/opt/gitops"
RUN mkdir -p $GITOPS_DIR/plugins $GITOPS_DIR/config $GITOPS_DIR/server-config

# 2. Copiamos tus JARs físicos ("static-plugins")
COPY docker/static-plugins/ $GITOPS_DIR/plugins/

# 3. Copiamos tus CONFIGURACIONES (El corazón de tu servidor)
COPY docker/configs/plugins/ $GITOPS_DIR/plugins/
COPY docker/configs/config/ $GITOPS_DIR/config/
COPY docker/configs/server.properties $GITOPS_DIR/server-config/

# 4. Copiamos el script de inyección
COPY docker/scripts/gitops-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/gitops-entrypoint.sh

# 5. Permisos: Aseguramos que el usuario 'minecraft' (UID 1000) sea dueño de esto
USER root
RUN chown -R 1000:1000 $GITOPS_DIR /usr/local/bin/gitops-entrypoint.sh
USER 1000