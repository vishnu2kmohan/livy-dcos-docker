FROM vishnumohan/miniconda3:4.3.30-3.6.3

MAINTAINER Vishnu Mohan <vishnu@mesosphere.com>

ARG DEBIAN_FRONTEND="noninteractive"
ARG LIBMESOS_BUNDLE_URL="https://downloads.mesosphere.com/libmesos-bundle"
ARG LIBMESOS_BUNDLE_VERSION="1.10-1.4-63e0814"
ARG LIBMESOS_BUNDLE_SHA256="cb81ae1211826afd4144f32fc30e6da6e122c85a5a8a3b13337c308dc2f6e69c"
ARG LIVY_GPG_KEY="12973FD0"
ARG LIVY_URL="https://www.apache.org/dist/incubator/livy"
ARG LIVY_VERSION="0.4.0-incubating"
ARG MESOS_JAR_SHA1="23a6aa96dc84560c7145aa0260bfb50acfc38dc0"
ARG MESOS_MAVEN_URL="https://repository.apache.org/service/local/repositories/releases/content/org/apache/mesos/mesos"
ARG MESOS_PROTOBUF_JAR_SHA1="1b259b2a8e36351600687b1460d1c021dbd73c34"
ARG MESOS_VERSION="1.4.1"

USER root
RUN cd /tmp \
    && curl --retry 3 -fsSL -O "${LIBMESOS_BUNDLE_URL}/libmesos-bundle-${LIBMESOS_BUNDLE_VERSION}.tar.gz" \
    && echo "${LIBMESOS_BUNDLE_SHA256}" "libmesos-bundle-${LIBMESOS_BUNDLE_VERSION}.tar.gz" | sha256sum -c - \
    && mkdir -p /opt/mesosphere /etc/hadoop/conf \
    && tar xzf "libmesos-bundle-${LIBMESOS_BUNDLE_VERSION}.tar.gz" -C /opt/mesosphere \
    && rm "libmesos-bundle-${LIBMESOS_BUNDLE_VERSION}.tar.gz"

USER "${CONDA_USER}"
COPY --chown="1000:100" livy-conda-env.yml "${HOME}/work/"
RUN cd "${HOME}" \
    && curl --retry 3 -fsSL -O "${LIVY_URL}/${LIVY_VERSION}/livy-${LIVY_VERSION}-bin.zip" \
    && curl --retry 3 -fsSL -O "${LIVY_URL}/${LIVY_VERSION}/livy-${LIVY_VERSION}-bin.zip.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver "${GPG_KEYSERVER}" --recv-keys "${LIVY_GPG_KEY}" \
    && gpg --batch --verify "livy-${LIVY_VERSION}-bin.zip.asc" "livy-${LIVY_VERSION}-bin.zip" \
    && rm -rf "$GNUPGHOME" "livy-${LIVY_VERSION}-bin.zip.asc" \
    && unzip "livy-${LIVY_VERSION}-bin.zip" \
    && rm "livy-${LIVY_VERSION}-bin.zip" \
    && mv "livy-${LIVY_VERSION}-bin" livy \
    && mkdir -p livy/logs \
    && cd livy/jars \
    && curl --retry 3 -fsSL -O "${MESOS_MAVEN_URL}/${MESOS_VERSION}/mesos-${MESOS_VERSION}.jar" \
    && echo "${MESOS_JAR_SHA1} mesos-${MESOS_VERSION}.jar" | sha1sum -c - \
    && curl --retry 3 -fsSL -O "${MESOS_MAVEN_URL}/${MESOS_VERSION}/mesos-${MESOS_VERSION}-shaded-protobuf.jar" \
    && echo "${MESOS_PROTOBUF_JAR_SHA1} mesos-${MESOS_VERSION}-shaded-protobuf.jar" | sha1sum -c - \
    && cd \
    && ${CONDA_DIR}/bin/conda env create --json -q -f "${HOME}/work/livy-conda-env.yml" \
    && ${CONDA_DIR}/bin/conda clean --json -tipsy

ENV MESOS_NATIVE_LIBRARY="/opt/mesosphere/libmesos-bundle/lib/libmesos.so" \
    MESOS_NATIVE_JAVA_LIBRARY="/opt/mesosphere/libmesos-bundle/lib/libmesos.so" \
    HADOOP_CONF_DIR="/etc/hadoop/conf"

COPY --chown="1000:100" log4j.properties "${HOME}/livy/conf/log4j.properties"
COPY livy.sh /usr/local/bin/

CMD ["livy.sh"]
