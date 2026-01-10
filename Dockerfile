# Usamos la base de itzg
FROM itzg/minecraft-server:java21

LABEL maintainer="Nicolas Estevez"
LABEL type="GitOps-Ready"

# 1. Definimos las rutas de "Staging" (Donde guardaremos tu repo dentro de la imagen)
ENV GITOPS_DIR="/opt/gitops"
RUN mkdir -p $GITOPS_DIR/plugins $GITOPS_DIR/config $GITOPS_DIR/server-config

# 3. Copiamos tus CONFIGURACIONES primero (carpetas de plugins)
COPY docker/configs/plugins/ $GITOPS_DIR/plugins/
COPY docker/configs/config/ $GITOPS_DIR/config/
COPY docker/configs/server.properties $GITOPS_DIR/server-config/

# 2. Copiamos tus JARs físicos DESPUÉS (para que no se sobrescriban)
COPY docker/static-plugins/*.jar $GITOPS_DIR/plugins/

# 4. Copiamos scripts de inyección y utilidades
COPY docker/scripts/*.sh /usr/local/bin/
# Corregir saltos de línea de Windows (CRLF -> LF) para evitar "required file not found"
RUN sed -i 's/\r$//' /usr/local/bin/*.sh
RUN chmod +x /usr/local/bin/*.sh

# 5. Permisos: Aseguramos que el usuario 'minecraft' (UID 1000) sea dueño de esto
USER root
RUN chown -R 1000:1000 $GITOPS_DIR /usr/local/bin/*.sh
USER 1000