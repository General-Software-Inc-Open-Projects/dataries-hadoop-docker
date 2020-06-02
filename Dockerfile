FROM openjdk:8-jdk-slim
LABEL version="2.9.2"
LABEL maintainer="Gilberto Muñoz <gilberto@generalsoftwareinc.com>"


ENV HADOOP_HOME=/opt/hadoop \
    HADOOP_VERION=2.9.2

ARG HADOOP_URL=https://non-root-registry.generalsoftwareinc.net/repository/apache-cache-registry/hadoop-${HADOOP_VERION}.tar.gz

RUN useradd -lrmU non-root

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \ 
        curl && \
    apt-get autoremove --yes && \
    apt-get clean

RUN curl ${HADOOP_URL} | tar -xz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERION} ${HADOOP_HOME} && \
    chown -R non-root:non-root ${HADOOP_HOME}

COPY --chown=non-root:non-root config_templates/ ${HADOOP_HOME}/etc/hadoop/

USER non-root

WORKDIR ${HADOOP_HOME}

COPY --chown=non-root:non-root healthcheck.sh entrypoint.sh /usr/bin/

ENTRYPOINT entrypoint.sh

HEALTHCHECK --interval=30s --timeout=15s --start-period=60s \
    CMD healthcheck.sh
