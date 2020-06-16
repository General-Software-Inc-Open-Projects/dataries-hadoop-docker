FROM openjdk:8-jdk-slim
LABEL version="3.2.1"
LABEL maintainer="Gilberto Muñoz <gilberto@generalsoftwareinc.com>"


ENV HADOOP_VERION="3.2.1" \
    HADOOP_HOME="/opt/hadoop"

ARG HADOOP_URL=https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERION}/hadoop-${HADOOP_VERION}.tar.gz

RUN set -eux; \
        useradd -lU hadoop

RUN  set -eux; \
        apt-get update; \
        apt-get install --yes --no-install-recommends \ 
            curl; \
        apt-get autoremove --yes; \
        apt-get clean

RUN set -eux; \
        curl ${HADOOP_URL} | tar -xz -C /opt && \
        mv /opt/hadoop-${HADOOP_VERION} ${HADOOP_HOME} && \
        chown -R hadoop:hadoop ${HADOOP_HOME}

ENV PATH="${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin"

USER hadoop

WORKDIR ${HADOOP_HOME}

COPY --chown=hadoop:hadoop healthcheck.sh entrypoint.sh /usr/bin/

ENTRYPOINT ["entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=15s --start-period=60s \
    CMD ["healthcheck.sh"]
